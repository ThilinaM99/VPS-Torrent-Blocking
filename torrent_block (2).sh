#!/bin/bash

# Advanced Torrent Blocking Script for VPS (Production Edition v3.0)
# Enhanced with duplicate prevention, monitoring, and webhook alerts
# Run as root or with sudo privileges

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="/opt/torrent-blocker"
CONFIG_FILE="$SCRIPT_DIR/config.conf"
LOG_FILE="/var/log/torrent-blocker.log"
TRACKER_FILE="$SCRIPT_DIR/hostsTrackers"
BACKUP_DIR="/root/torrent-block-backup-$(date +%Y%m%d_%H%M%S)"

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
}

# Save configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
# Torrent Blocker Configuration
WEBHOOK_ENABLED=${WEBHOOK_ENABLED:-false}
WEBHOOK_TYPE=${WEBHOOK_TYPE:-none}
WEBHOOK_URL=${WEBHOOK_URL:-}
ALERT_THRESHOLD=${ALERT_THRESHOLD:-100}
LOG_SYSTEM_LOAD=${LOG_SYSTEM_LOAD:-true}
EOF
}

log() {
    echo -e "${2}${1}${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Send webhook notification
send_webhook() {
    local message="$1"
    
    [ "$WEBHOOK_ENABLED" != "true" ] && return 0
    [ -z "$WEBHOOK_URL" ] && return 0
    
    case "$WEBHOOK_TYPE" in
        discord)
            curl -s -H "Content-Type: application/json" -X POST -d "{\"content\":\"🛡️ **Torrent Blocker Alert**\n$message\"}" "$WEBHOOK_URL" > /dev/null 2>&1
            ;;
        telegram)
            local chat_id=$(echo "$WEBHOOK_URL" | grep -oP 'chat_id=\K[^&]+')
            local bot_token=$(echo "$WEBHOOK_URL" | grep -oP 'bot\K[^/]+')
            curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
                -d "chat_id=${chat_id}" \
                -d "text=🛡️ Torrent Blocker Alert: $message" > /dev/null 2>&1
            ;;
        slack)
            curl -s -X POST -H 'Content-type: application/json' \
                --data "{\"text\":\"🛡️ Torrent Blocker Alert: $message\"}" \
                "$WEBHOOK_URL" > /dev/null 2>&1
            ;;
    esac
}

# Get system load information
get_system_load() {
    local load_avg=$(uptime | awk -F'load average:' '{print $2}')
    local cpu_count=$(nproc)
    local load_1min=$(echo $load_avg | awk '{print $1}' | tr -d ',')
    local load_percent=$(echo "scale=2; ($load_1min / $cpu_count) * 100" | bc)
    
    echo "Load: $load_avg (${load_percent}% of ${cpu_count} CPUs)"
}

# Log system metrics
log_system_metrics() {
    if [ "$LOG_SYSTEM_LOAD" = "true" ]; then
        local load_info=$(get_system_load)
        local mem_info=$(free -h | grep Mem | awk '{print "Memory: "$3"/"$2" used"}')
        local conn_info=$(cat /proc/sys/net/netfilter/nf_conntrack_count 2>/dev/null || echo "0")
        local conn_max=$(sysctl -n net.netfilter.nf_conntrack_max 2>/dev/null || echo "0")
        
        log "System Metrics:" "$CYAN"
        log "  $load_info" "$NC"
        log "  $mem_info" "$NC"
        log "  Connections: $conn_info/$conn_max" "$NC"
    fi
}

echo -e "${GREEN}=========================================="
echo "  Advanced Torrent Blocking Script v3.0"
echo "  with Monitoring & Alerts"
echo "==========================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log "Error: This script must be run as root" "$RED"
   exit 1
fi

# Create directories
mkdir -p "$SCRIPT_DIR"
mkdir -p "$BACKUP_DIR"

# Load existing config
load_config

# Initial configuration for first-time install
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${CYAN}First-time setup: Configure webhook alerts (optional)${NC}"
    echo ""
    read -p "Enable webhook notifications? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        WEBHOOK_ENABLED=true
        echo ""
        echo "Select webhook type:"
        echo "  1) Discord"
        echo "  2) Telegram"
        echo "  3) Slack"
        read -p "Enter choice (1-3): " webhook_choice
        
        case $webhook_choice in
            1)
                WEBHOOK_TYPE="discord"
                read -p "Enter Discord webhook URL: " WEBHOOK_URL
                ;;
            2)
                WEBHOOK_TYPE="telegram"
                echo "Format: https://api.telegram.org/botTOKEN/sendMessage?chat_id=CHAT_ID"
                read -p "Enter Telegram webhook URL: " WEBHOOK_URL
                ;;
            3)
                WEBHOOK_TYPE="slack"
                read -p "Enter Slack webhook URL: " WEBHOOK_URL
                ;;
            *)
                WEBHOOK_ENABLED=false
                ;;
        esac
        
        if [ "$WEBHOOK_ENABLED" = "true" ]; then
            read -p "Alert threshold (min new IPs to trigger alert, default 100): " threshold
            ALERT_THRESHOLD=${threshold:-100}
        fi
    else
        WEBHOOK_ENABLED=false
    fi
    
    save_config
    echo ""
fi

# Check UFW status
if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
    log "⚠️  WARNING: UFW is active!" "$YELLOW"
    echo ""
    read -p "UFW may conflict with iptables rules. Disable UFW? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ufw disable
        log "UFW disabled successfully" "$GREEN"
    else
        log "Continuing with UFW active. Rules may conflict!" "$YELLOW"
        echo "Press Enter to continue or Ctrl+C to abort..."
        read
    fi
fi

# Install required packages
log "[1/10] Installing required packages..." "$YELLOW"
if command -v apt-get &> /dev/null; then
    apt-get update -qq
    apt-get install -y iptables ipset iptables-persistent curl wget dnsmasq conntrack bc > /dev/null 2>&1
elif command -v yum &> /dev/null; then
    yum install -y iptables ipset iptables-services curl wget dnsmasq conntrack-tools bc > /dev/null 2>&1
else
    log "Error: Package manager not recognized" "$RED"
    exit 1
fi

# Backup existing configuration
log "[2/10] Backing up existing configuration..." "$YELLOW"
cp /etc/hosts "$BACKUP_DIR/hosts.backup" 2>/dev/null || true
iptables-save > "$BACKUP_DIR/iptables.backup" 2>/dev/null || true
ipset save > "$BACKUP_DIR/ipset.backup" 2>/dev/null || true

# Optimize kernel for connection tracking
log "[3/10] Optimizing kernel parameters..." "$YELLOW"

# Only add if not already present
if ! grep -q "Torrent Blocking Performance Optimizations" /etc/sysctl.conf; then
    cat >> /etc/sysctl.conf << 'EOF'

# Torrent Blocking Performance Optimizations
net.netfilter.nf_conntrack_max = 524288
net.netfilter.nf_conntrack_tcp_timeout_established = 1200
net.netfilter.nf_conntrack_generic_timeout = 120
net.core.netdev_max_backlog = 5000
EOF
    sysctl -p > /dev/null 2>&1
fi

# Create optimized ipsets
log "[4/10] Creating optimized ipset lists..." "$YELLOW"
ipset create -exist torrent_trackers hash:ip hashsize 4096 maxelem 65536 timeout 0
ipset create -exist torrent_sites hash:ip hashsize 4096 maxelem 65536 timeout 0
ipset create -exist torrent_connections hash:ip,port hashsize 4096 maxelem 65536 timeout 300

# Get initial counts
INITIAL_TRACKER_COUNT=$(ipset list torrent_trackers 2>/dev/null | grep -c "^[0-9]" || echo "0")
INITIAL_SITE_COUNT=$(ipset list torrent_sites 2>/dev/null | grep -c "^[0-9]" || echo "0")

# Download tracker list
log "[5/10] Downloading public tracker list..." "$YELLOW"

cat > "$TRACKER_FILE" << 'EOF'
# Public BitTorrent Trackers - Auto-updated list
tracker.opentrackr.org
tracker.openbittorrent.com
tracker.thepiratebay.org
tracker.coppersurfer.tk
tracker.leechers-paradise.org
tracker.internetwarriors.net
tracker.zer0day.to
tracker.pirateparty.gr
tracker.cyberia.is
tracker.tiny-vps.com
tracker.torrent.eu.org
tracker.moeking.me
retracker.lanta-net.ru
open.stealth.si
denis.stalker.upeer.me
exodus.desync.com
tracker2.dler.org
valakas.rollo.dnsabr.com
open.tracker.ink
tracker1.itzmx.com
tracker.lelux.fi
tracker.dler.org
vibe.sleepyinternetfun.xyz
torrents.artixlinux.org
ipv6.tracker.harry.lu
tracker.datacorp.com
open.demonii.com
tracker.pomf.se
tracker.publicbt.com
tracker.istole.it
tracker.ccc.de
bt.xxx-tracker.com
bt1.archive.org
bt2.archive.org
ipv4.tracker.harry.lu
tracker.files.fm
9.rarbg.to
9.rarbg.me
tracker.mg64.net
inferno.demonoid.is
tracker.port443.xyz
tracker.ds.is
tracker.altrosky.nl
retracker.hotplug.ru
tracker2.itzmx.com
tracker.swateam.org.uk
tracker.uw0.xyz
tracker.nyaa.uk
tracker.iriseden.fr
tracker.gbitt.info
tracker.filemail.com
tracker.novg.net
tracker.skynetcloud.tk
EOF

# Function to update tracker IPs (prevents duplicates)
update_tracker_ips() {
    local count=0
    while IFS= read -r domain; do
        [[ "$domain" =~ ^#.*$ || -z "$domain" ]] && continue
        
        # Prevent duplicate entries in hosts file
        grep -q "0.0.0.0 $domain" /etc/hosts || echo "0.0.0.0 $domain" >> /etc/hosts
        
        IPS=$(timeout 2 dig +short "$domain" A 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
        for IP in $IPS; do
            ipset add torrent_trackers "$IP" -exist 2>/dev/null || true
            ((count++))
        done
    done < "$TRACKER_FILE"
    echo "$count"
}

TRACKER_COUNT=$(update_tracker_ips)
log "  Resolved and blocked $TRACKER_COUNT tracker IPs" "$GREEN"

# Block torrent sites
log "[6/10] Blocking torrent websites..." "$YELLOW"

TORRENT_SITES=(
    "thepiratebay.org" "1337x.to" "rarbg.to" "yts.mx" "eztv.re"
    "torrentz2.eu" "limetorrents.pro" "kickasstorrents.to"
    "torlock.com" "zooqle.com" "magnetdl.com" "glodls.to"
    "ettv.to" "skytorrents.to" "torrentgalaxy.to"
    "nyaa.si" "torrentdownloads.me" "fitgirl-repacks.site"
    "rutracker.org" "btdb.eu" "idope.se" "isohunt.to"
)

SITE_COUNT=0
for site in "${TORRENT_SITES[@]}"; do
    for prefix in "" "www." "proxy." "mobile." "m." "cdn." "api."; do
        # Prevent duplicate entries
        grep -q "0.0.0.0 ${prefix}${site}" /etc/hosts || echo "0.0.0.0 ${prefix}${site}" >> /etc/hosts
    done
    
    IPS=$(timeout 2 dig +short "$site" A 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
    for IP in $IPS; do
        ipset add torrent_sites "$IP" -exist 2>/dev/null || true
        ((SITE_COUNT++))
    done
done
log "  Resolved and blocked $SITE_COUNT site IPs" "$GREEN"

# Calculate new IPs added
FINAL_TRACKER_COUNT=$(ipset list torrent_trackers 2>/dev/null | grep -c "^[0-9]" || echo "0")
FINAL_SITE_COUNT=$(ipset list torrent_sites 2>/dev/null | grep -c "^[0-9]" || echo "0")
NEW_TRACKER_IPS=$((FINAL_TRACKER_COUNT - INITIAL_TRACKER_COUNT))
NEW_SITE_IPS=$((FINAL_SITE_COUNT - INITIAL_SITE_COUNT))
TOTAL_NEW_IPS=$((NEW_TRACKER_IPS + NEW_SITE_IPS))

# Send webhook alert if threshold exceeded
if [ $TOTAL_NEW_IPS -gt $ALERT_THRESHOLD ]; then
    send_webhook "Added $TOTAL_NEW_IPS new IPs ($NEW_TRACKER_IPS trackers, $NEW_SITE_IPS sites). Total blocked: $FINAL_TRACKER_COUNT trackers, $FINAL_SITE_COUNT sites."
fi

# Optimized iptables rules
log "[7/10] Creating optimized iptables rules..." "$YELLOW"

# Use conntrack for better performance
iptables -I INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
iptables -I OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true

# Block ipset-based IPs efficiently
iptables -I INPUT -m set --match-set torrent_trackers src -j DROP 2>/dev/null || true
iptables -I OUTPUT -m set --match-set torrent_trackers dst -j DROP 2>/dev/null || true
iptables -I FORWARD -m set --match-set torrent_trackers dst -j DROP 2>/dev/null || true

iptables -I INPUT -m set --match-set torrent_sites src -j DROP 2>/dev/null || true
iptables -I OUTPUT -m set --match-set torrent_sites dst -j DROP 2>/dev/null || true
iptables -I FORWARD -m set --match-set torrent_sites dst -j DROP 2>/dev/null || true

# Block common BitTorrent port ranges efficiently
iptables -I INPUT -p tcp -m multiport --dports 6881:6900,51413 -j DROP 2>/dev/null || true
iptables -I OUTPUT -p tcp -m multiport --dports 6881:6900,51413 -j DROP 2>/dev/null || true
iptables -I INPUT -p udp -m multiport --dports 6881:6900,51413 -j DROP 2>/dev/null || true
iptables -I OUTPUT -p udp -m multiport --dports 6881:6900,51413 -j DROP 2>/dev/null || true

# Limited DPI rules for critical patterns only
log "[8/10] Implementing selective deep packet inspection..." "$YELLOW"
log "  ⚠️  Note: DPI rules may not catch encrypted torrents" "$YELLOW"

iptables -I OUTPUT -m string --algo bm --string "BitTorrent protocol" -j DROP 2>/dev/null || true
iptables -I OUTPUT -m string --algo bm --string "info_hash" -j DROP 2>/dev/null || true
iptables -I OUTPUT -m string --algo bm --string ".torrent" -j DROP 2>/dev/null || true

# Save rules
log "[9/10] Saving configuration..." "$YELLOW"

if command -v netfilter-persistent &> /dev/null; then
    netfilter-persistent save > /dev/null 2>&1
elif command -v iptables-save &> /dev/null; then
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || iptables-save > /etc/sysconfig/iptables
fi

ipset save > /etc/ipset.conf 2>/dev/null || true

# Create systemd service for ipset persistence
if [ ! -f /etc/systemd/system/ipset-persistent.service ]; then
    cat > /etc/systemd/system/ipset-persistent.service << 'EOFS'
[Unit]
Description=ipset persistent configuration
Before=network.target
Before=netfilter-persistent.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/sbin/ipset restore -f /etc/ipset.conf
ExecStop=/sbin/ipset save -f /etc/ipset.conf

[Install]
WantedBy=multi-user.target
EOFS

    systemctl daemon-reload
    systemctl enable ipset-persistent.service 2>/dev/null || true
fi

# Create auto-update script
log "[10/10] Setting up automatic updates..." "$YELLOW"

cat > "$SCRIPT_DIR/update-trackers.sh" << 'EOFUPDATE'
#!/bin/bash
# Auto-update tracker IPs
LOG_FILE="/var/log/torrent-blocker.log"
TRACKER_FILE="/opt/torrent-blocker/hostsTrackers"
CONFIG_FILE="/opt/torrent-blocker/config.conf"

source "$CONFIG_FILE" 2>/dev/null || true

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting tracker IP update..." >> "$LOG_FILE"

# Get initial count
INITIAL_COUNT=$(ipset list torrent_trackers 2>/dev/null | grep -c "^[0-9]" || echo "0")

count=0
while IFS= read -r domain; do
    [[ "$domain" =~ ^#.*$ || -z "$domain" ]] && continue
    
    # Prevent duplicates in hosts file
    grep -q "0.0.0.0 $domain" /etc/hosts || echo "0.0.0.0 $domain" >> /etc/hosts
    
    IPS=$(timeout 2 dig +short "$domain" A 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
    for IP in $IPS; do
        ipset add torrent_trackers "$IP" -exist 2>/dev/null || true
        ((count++))
    done
done < "$TRACKER_FILE"

ipset save > /etc/ipset.conf 2>/dev/null

# Get final count
FINAL_COUNT=$(ipset list torrent_trackers 2>/dev/null | grep -c "^[0-9]" || echo "0")
NEW_IPS=$((FINAL_COUNT - INITIAL_COUNT))

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Updated: $count resolutions, $NEW_IPS new IPs (Total: $FINAL_COUNT)" >> "$LOG_FILE"

# Log system load
if [ "$LOG_SYSTEM_LOAD" = "true" ]; then
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] System load:$LOAD_AVG" >> "$LOG_FILE"
fi

# Send webhook if threshold exceeded
if [ "$WEBHOOK_ENABLED" = "true" ] && [ $NEW_IPS -gt ${ALERT_THRESHOLD:-100} ]; then
    case "$WEBHOOK_TYPE" in
        discord)
            curl -s -H "Content-Type: application/json" -X POST -d "{\"content\":\"🔄 **Torrent Blocker Update**\nAdded $NEW_IPS new tracker IPs. Total: $FINAL_COUNT\"}" "$WEBHOOK_URL" > /dev/null 2>&1
            ;;
        telegram)
            CHAT_ID=$(echo "$WEBHOOK_URL" | grep -oP 'chat_id=\K[^&]+')
            BOT_TOKEN=$(echo "$WEBHOOK_URL" | grep -oP 'bot\K[^/]+')
            curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
                -d "chat_id=${CHAT_ID}" \
                -d "text=🔄 Torrent Blocker Update: Added $NEW_IPS new tracker IPs. Total: $FINAL_COUNT" > /dev/null 2>&1
            ;;
        slack)
            curl -s -X POST -H 'Content-type: application/json' \
                --data "{\"text\":\"🔄 Torrent Blocker Update: Added $NEW_IPS new tracker IPs. Total: $FINAL_COUNT\"}" \
                "$WEBHOOK_URL" > /dev/null 2>&1
            ;;
    esac
fi
EOFUPDATE

chmod +x "$SCRIPT_DIR/update-trackers.sh"

# Setup daily cron job at 3 AM (prevent duplicate)
(crontab -l 2>/dev/null | grep -v "update-trackers.sh"; echo "0 3 * * * $SCRIPT_DIR/update-trackers.sh") | crontab -

log "  ✓ Daily auto-update configured (3 AM)" "$GREEN"

# Create management script
cat > "$SCRIPT_DIR/torrent-blocker-manager.sh" << 'EOFMGR'
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_FILE="/opt/torrent-blocker/config.conf"
source "$CONFIG_FILE" 2>/dev/null || true

show_status() {
    echo -e "${BLUE}=========================================="
    echo "  Torrent Blocker Status"
    echo -e "==========================================${NC}"
    echo ""
    
    TRACKER_IPS=$(ipset list torrent_trackers 2>/dev/null | grep -c "^[0-9]" || echo "0")
    SITE_IPS=$(ipset list torrent_sites 2>/dev/null | grep -c "^[0-9]" || echo "0")
    RULES_COUNT=$(iptables -L -n | grep -c DROP || echo "0")
    
    echo -e "${GREEN}Tracker IPs blocked:${NC} $TRACKER_IPS"
    echo -e "${GREEN}Site IPs blocked:${NC} $SITE_IPS"
    echo -e "${GREEN}Active iptables rules:${NC} $RULES_COUNT"
    echo ""
    
    # System load
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')
    CPU_COUNT=$(nproc)
    MEM_USED=$(free -h | grep Mem | awk '{print $3"/"$2}')
    CONN_CURRENT=$(cat /proc/sys/net/netfilter/nf_conntrack_count 2>/dev/null || echo "0")
    CONN_MAX=$(sysctl -n net.netfilter.nf_conntrack_max 2>/dev/null || echo "0")
    
    echo -e "${CYAN}System Metrics:${NC}"
    echo -e "  Load average:$LOAD_AVG (${CPU_COUNT} CPUs)"
    echo -e "  Memory: $MEM_USED"
    echo -e "  Connections: $CONN_CURRENT/$CONN_MAX"
    echo ""
    
    # Webhook status
    echo -e "${CYAN}Webhook Alerts:${NC}"
    if [ "$WEBHOOK_ENABLED" = "true" ]; then
        echo -e "  ${GREEN}✓${NC} Enabled ($WEBHOOK_TYPE)"
        echo -e "  Alert threshold: $ALERT_THRESHOLD new IPs"
    else
        echo -e "  ${YELLOW}✗${NC} Disabled"
    fi
    echo ""
    
    echo -e "${YELLOW}Recent activity (last 24h):${NC}"
    grep "$(date '+%Y-%m-%d')" /var/log/torrent-blocker.log 2>/dev/null | tail -5 || echo "  No recent activity"
}

update_now() {
    echo -e "${YELLOW}Updating tracker IPs...${NC}"
    /opt/torrent-blocker/update-trackers.sh
    echo -e "${GREEN}✓ Update complete!${NC}"
}

configure_webhook() {
    echo -e "${CYAN}Webhook Configuration${NC}"
    echo ""
    read -p "Enable webhooks? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sed -i 's/WEBHOOK_ENABLED=.*/WEBHOOK_ENABLED=true/' "$CONFIG_FILE"
        
        echo "Select type:"
        echo "  1) Discord"
        echo "  2) Telegram"
        echo "  3) Slack"
        read -p "Choice: " choice
        
        case $choice in
            1) sed -i 's/WEBHOOK_TYPE=.*/WEBHOOK_TYPE=discord/' "$CONFIG_FILE" ;;
            2) sed -i 's/WEBHOOK_TYPE=.*/WEBHOOK_TYPE=telegram/' "$CONFIG_FILE" ;;
            3) sed -i 's/WEBHOOK_TYPE=.*/WEBHOOK_TYPE=slack/' "$CONFIG_FILE" ;;
        esac
        
        read -p "Webhook URL: " url
        sed -i "s|WEBHOOK_URL=.*|WEBHOOK_URL=$url|" "$CONFIG_FILE"
        
        read -p "Alert threshold (default 100): " threshold
        sed -i "s/ALERT_THRESHOLD=.*/ALERT_THRESHOLD=${threshold:-100}/" "$CONFIG_FILE"
        
        echo -e "${GREEN}✓ Webhook configured!${NC}"
    else
        sed -i 's/WEBHOOK_ENABLED=.*/WEBHOOK_ENABLED=false/' "$CONFIG_FILE"
        echo -e "${GREEN}✓ Webhooks disabled${NC}"
    fi
}

uninstall() {
    echo -e "${RED}Uninstalling torrent blocker...${NC}"
    
    iptables -D INPUT -m set --match-set torrent_trackers src -j DROP 2>/dev/null || true
    iptables -D OUTPUT -m set --match-set torrent_trackers dst -j DROP 2>/dev/null || true
    iptables -D FORWARD -m set --match-set torrent_trackers dst -j DROP 2>/dev/null || true
    iptables -D INPUT -m set --match-set torrent_sites src -j DROP 2>/dev/null || true
    iptables -D OUTPUT -m set --match-set torrent_sites dst -j DROP 2>/dev/null || true
    iptables -D FORWARD -m set --match-set torrent_sites dst -j DROP 2>/dev/null || true
    
    ipset destroy torrent_trackers 2>/dev/null || true
    ipset destroy torrent_sites 2>/dev/null || true
    ipset destroy torrent_connections 2>/dev/null || true
    
    sed -i '/0.0.0.0.*tracker/d' /etc/hosts
    sed -i '/0.0.0.0.*torrent/d' /etc/hosts
    
    crontab -l 2>/dev/null | grep -v "update-trackers.sh" | crontab -
    
    netfilter-persistent save 2>/dev/null || iptables-save > /etc/iptables/rules.v4
    
    echo -e "${GREEN}✓ Uninstall complete!${NC}"
}

case "$1" in
    status)
        show_status
        ;;
    update)
        update_now
        ;;
    webhook)
        configure_webhook
        ;;
    uninstall)
        uninstall
        ;;
    *)
        echo "Usage: $0 {status|update|webhook|uninstall}"
        echo ""
        echo "  status     - Show blocking statistics and system metrics"
        echo "  update     - Update tracker IPs immediately"
        echo "  webhook    - Configure webhook alerts"
        echo "  uninstall  - Remove all torrent blocking rules"
        exit 1
        ;;
esac
EOFMGR

chmod +x "$SCRIPT_DIR/torrent-blocker-manager.sh"

# Create convenient alias (prevent duplicate)
grep -q "alias torrent-blocker=" /root/.bashrc || echo "alias torrent-blocker='$SCRIPT_DIR/torrent-blocker-manager.sh'" >> /root/.bashrc

# Log final system metrics
log_system_metrics

echo ""
echo -e "${GREEN}=========================================="
echo "  Installation Complete!"
echo "==========================================${NC}"
echo ""
echo -e "${GREEN}✓${NC} Blocked $FINAL_TRACKER_COUNT tracker IPs ($NEW_TRACKER_IPS new)"
echo -e "${GREEN}✓${NC} Blocked $FINAL_SITE_COUNT site IPs ($NEW_SITE_IPS new)"
echo -e "${GREEN}✓${NC} Optimized iptables with conntrack"
echo -e "${GREEN}✓${NC} Duplicate prevention in /etc/hosts"
echo -e "${GREEN}✓${NC} Daily auto-updates at 3 AM"
echo -e "${GREEN}✓${NC} System load monitoring enabled"
if [ "$WEBHOOK_ENABLED" = "true" ]; then
    echo -e "${GREEN}✓${NC} Webhook alerts configured ($WEBHOOK_TYPE)"
fi
echo ""
echo -e "${YELLOW}Management Commands:${NC}"
echo -e "  ${BLUE}torrent-blocker status${NC}     - View statistics & system load"
echo -e "  ${BLUE}torrent-blocker update${NC}     - Update tracker IPs now"
echo -e "  ${BLUE}torrent-blocker webhook${NC}    - Configure webhook alerts"
echo -e "  ${BLUE}torrent-blocker uninstall${NC}  - Remove everything"
echo ""
echo -e "${YELLOW}Manual Commands:${NC}"
echo "  View rules:     iptables -L -n -v | grep DROP"
echo "  View trackers:  ipset list torrent_trackers | head -20"
echo "  View logs:      tail -f /var/log/torrent-blocker.log"
echo "  System load:    uptime"
echo ""
echo -e "${YELLOW}⚠️  Important Notes:${NC}"
echo "  • DPI rules won't catch encrypted torrents"
echo "  • /etc/hosts duplicates prevented with grep check"
echo "  • System load logged after each operation"
echo "  • Webhook alerts when new IPs > $ALERT_THRESHOLD"
echo "  • Backup saved at: $BACKUP_DIR"
echo ""

# Log completion metrics
log "Installation completed successfully!" "$GREEN"
log "Total IPs blocked: Trackers=$FINAL_TRACKER_COUNT, Sites=$FINAL_SITE_COUNT" "$GREEN"

# Send installation complete webhook
if [ "$WEBHOOK_ENABLED" = "true" ]; then
    send_webhook "Installation complete! Blocking $FINAL_TRACKER_COUNT tracker IPs and $FINAL_SITE_COUNT site IPs. System load: $(get_system_load)"
fi

echo -e "${GREEN}==========================================${NC}"