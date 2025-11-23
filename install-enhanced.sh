#!/bin/bash

# Enhanced Torrent & P2P Blocking Installation Script
# This script installs comprehensive torrent blocking with all improvements
# Supports both iptables and nftables

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="/opt/torrent-blocking"
BLOCKLIST_DIR="/etc/torrent-blocklists"
LOG_DIR="/var/log/torrent-blocking"
BACKUP_DIR="/var/backups/torrent-blocking"

# Function to print colored output
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        echo "Please run: sudo bash install-enhanced.sh"
        exit 1
    fi
}

# Detect firewall system
detect_firewall() {
    if command -v nft &> /dev/null; then
        FIREWALL="nftables"
        print_info "Detected: nftables"
    elif command -v iptables &> /dev/null; then
        FIREWALL="iptables"
        print_info "Detected: iptables"
    else
        print_error "Neither nftables nor iptables found"
        exit 1
    fi
}

# Create necessary directories
create_directories() {
    print_info "Creating directories..."
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BLOCKLIST_DIR"
    mkdir -p "$LOG_DIR"
    mkdir -p "$BACKUP_DIR"
    print_success "Directories created"
}

# Backup existing configurations
backup_configs() {
    print_info "Backing up existing configurations..."
    
    if [ -f /etc/hosts ]; then
        cp /etc/hosts "$BACKUP_DIR/hosts.backup.$(date +%s)"
    fi
    
    if [ -f /etc/trackers ]; then
        cp /etc/trackers "$BACKUP_DIR/trackers.backup.$(date +%s)"
    fi
    
    print_success "Configurations backed up to $BACKUP_DIR"
}

# Download blocklists
download_blocklists() {
    print_info "Downloading torrent blocklists..."
    
    # Download domains list
    if wget -q -O "$BLOCKLIST_DIR/domains.txt" \
        https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/domains; then
        print_success "Downloaded domains list"
    else
        print_error "Failed to download domains list"
        return 1
    fi
    
    # Download hosts file
    if wget -q -O "$BLOCKLIST_DIR/hosts.txt" \
        https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/Thosts; then
        print_success "Downloaded hosts file"
    else
        print_error "Failed to download hosts file"
        return 1
    fi
    
    # Use local files if available
    if [ -f "domains" ]; then
        cp domains "$BLOCKLIST_DIR/domains.txt"
    fi
    
    if [ -f "Thosts" ]; then
        cp Thosts "$BLOCKLIST_DIR/hosts.txt"
    fi
}

# Setup DNS-level blocking with hosts file
setup_hosts_blocking() {
    print_info "Setting up hosts file blocking..."
    
    if [ -f "$BLOCKLIST_DIR/hosts.txt" ]; then
        # Backup original hosts
        cp /etc/hosts "$BACKUP_DIR/hosts.original"
        
        # Merge hosts file
        grep -v "^0.0.0.0" /etc/hosts > /tmp/hosts.tmp || true
        cat "$BLOCKLIST_DIR/hosts.txt" >> /tmp/hosts.tmp
        sort -u /tmp/hosts.tmp > /etc/hosts
        rm /tmp/hosts.tmp
        
        print_success "Hosts file blocking configured"
    fi
}

# Setup iptables blocking
setup_iptables_blocking() {
    print_info "Setting up iptables blocking..."
    
    if [ ! -f "$BLOCKLIST_DIR/domains.txt" ]; then
        print_error "Domains list not found"
        return 1
    fi
    
    # Create cron job for daily updates
    cat > /etc/cron.daily/torrent-block-iptables <<'CRONEOF'
#!/bin/bash
BLOCKLIST_DIR="/etc/torrent-blocklists"
DOMAINS_FILE="$BLOCKLIST_DIR/domains.txt"

if [ ! -f "$DOMAINS_FILE" ]; then
    exit 1
fi

IFS=$'\n'
for domain in $(sort -u "$DOMAINS_FILE"); do
    [ -z "$domain" ] && continue
    
    # Remove old rules
    /sbin/iptables -D INPUT -d "$domain" -j DROP 2>/dev/null || true
    /sbin/iptables -D FORWARD -d "$domain" -j DROP 2>/dev/null || true
    /sbin/iptables -D OUTPUT -d "$domain" -j DROP 2>/dev/null || true
    
    # Add new rules
    /sbin/iptables -A INPUT -d "$domain" -j DROP
    /sbin/iptables -A FORWARD -d "$domain" -j DROP
    /sbin/iptables -A OUTPUT -d "$domain" -j DROP
done

# Save iptables rules
iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
CRONEOF
    
    chmod +x /etc/cron.daily/torrent-block-iptables
    
    # Run initial blocking
    /etc/cron.daily/torrent-block-iptables
    
    print_success "iptables blocking configured"
}

# Setup nftables blocking
setup_nftables_blocking() {
    print_info "Setting up nftables blocking..."
    
    if [ ! -f "$BLOCKLIST_DIR/domains.txt" ]; then
        print_error "Domains list not found"
        return 1
    fi
    
    # Create nftables table and chain
    nft list tables | grep -q 'torrentblock' || \
        nft add table inet torrentblock
    
    nft list chains inet torrentblock 2>/dev/null | grep -q 'domainblock' || \
        nft add chain inet torrentblock domainblock { type filter hook output priority 0 \; }
    
    # Flush old rules
    nft flush chain inet torrentblock domainblock
    
    # Add blocking rules
    while IFS= read -r domain; do
        [ -z "$domain" ] && continue
        
        # Resolve domain to IP and add rule
        ip=$(getent ahosts "$domain" 2>/dev/null | awk '{print $1}' | head -n 1)
        if [ -n "$ip" ]; then
            nft add rule inet torrentblock domainblock ip daddr "$ip" drop 2>/dev/null || true
        fi
    done < "$BLOCKLIST_DIR/domains.txt"
    
    # Create cron job for daily updates
    cat > /etc/cron.daily/torrent-block-nftables <<'CRONEOF'
#!/bin/bash
BLOCKLIST_DIR="/etc/torrent-blocklists"
DOMAINS_FILE="$BLOCKLIST_DIR/domains.txt"

if [ ! -f "$DOMAINS_FILE" ]; then
    exit 1
fi

nft flush chain inet torrentblock domainblock 2>/dev/null || exit 1

while IFS= read -r domain; do
    [ -z "$domain" ] && continue
    ip=$(getent ahosts "$domain" 2>/dev/null | awk '{print $1}' | head -n 1)
    if [ -n "$ip" ]; then
        nft add rule inet torrentblock domainblock ip daddr "$ip" drop 2>/dev/null || true
    fi
done < "$DOMAINS_FILE"
CRONEOF
    
    chmod +x /etc/cron.daily/torrent-block-nftables
    
    print_success "nftables blocking configured"
}

# Setup port blocking
setup_port_blocking() {
    print_info "Setting up BitTorrent port blocking..."
    
    TORRENT_PORTS=(
        6881 6882 6883 6884 6885 6886 6887 6888 6889
        6969 51413 4662 4672
    )
    
    if [ "$FIREWALL" = "iptables" ]; then
        for port in "${TORRENT_PORTS[@]}"; do
            iptables -D INPUT -p tcp --dport "$port" -j DROP 2>/dev/null || true
            iptables -D INPUT -p udp --dport "$port" -j DROP 2>/dev/null || true
            iptables -A INPUT -p tcp --dport "$port" -j DROP
            iptables -A INPUT -p udp --dport "$port" -j DROP
        done
        iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
    elif [ "$FIREWALL" = "nftables" ]; then
        nft list chains inet torrentblock | grep -q '^chain portblock$' || \
            nft add chain inet torrentblock portblock { type filter hook input priority 0 \; }
        
        nft flush chain inet torrentblock portblock
        
        for port in "${TORRENT_PORTS[@]}"; do
            nft add rule inet torrentblock portblock tcp dport "$port" drop
            nft add rule inet torrentblock portblock udp dport "$port" drop
        done
    fi
    
    print_success "Port blocking configured"
}

# Setup monitoring and logging
setup_monitoring() {
    print_info "Setting up monitoring and logging..."
    
    # Create logging directory with proper permissions
    mkdir -p "$LOG_DIR"
    chmod 755 "$LOG_DIR"
    
    # Create monitoring script
    cat > "$INSTALL_DIR/monitor-blocking.sh" <<'MONEOF'
#!/bin/bash
LOG_DIR="/var/log/torrent-blocking"
STATS_FILE="$LOG_DIR/blocking-stats.txt"

echo "=== Torrent Blocking Statistics ===" > "$STATS_FILE"
echo "Generated: $(date)" >> "$STATS_FILE"
echo "" >> "$STATS_FILE"

if [ -f "$LOG_DIR/blocked-domains.log" ]; then
    BLOCK_COUNT=$(wc -l < "$LOG_DIR/blocked-domains.log")
    echo "Total blocked attempts: $BLOCK_COUNT" >> "$STATS_FILE"
fi

echo "Active iptables rules:" >> "$STATS_FILE"
iptables -L -n 2>/dev/null | grep DROP | wc -l >> "$STATS_FILE"

echo "Active nftables rules:" >> "$STATS_FILE"
nft list ruleset 2>/dev/null | grep drop | wc -l >> "$STATS_FILE"
MONEOF
    
    chmod +x "$INSTALL_DIR/monitor-blocking.sh"
    
    # Create daily stats cron job
    cat > /etc/cron.daily/torrent-blocking-stats <<'CRONEOF'
#!/bin/bash
/opt/torrent-blocking/monitor-blocking.sh
CRONEOF
    
    chmod +x /etc/cron.daily/torrent-blocking-stats
    
    print_success "Monitoring configured"
}

# Setup auto-update
setup_auto_update() {
    print_info "Setting up automatic blocklist updates..."
    
    cat > "$INSTALL_DIR/update-blocklist.sh" <<'UPDATEEOF'
#!/bin/bash
BLOCKLIST_DIR="/etc/torrent-blocklists"
BACKUP_DIR="/var/backups/torrent-blocking"

echo "[$(date)] Starting blocklist update..." >> "$BLOCKLIST_DIR/update.log"

# Download latest lists
wget -q -O "$BLOCKLIST_DIR/domains.txt.new" \
    https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/domains

if [ -f "$BLOCKLIST_DIR/domains.txt.new" ]; then
    # Backup old list
    [ -f "$BLOCKLIST_DIR/domains.txt" ] && \
        cp "$BLOCKLIST_DIR/domains.txt" "$BACKUP_DIR/domains.backup.$(date +%s)"
    
    # Replace with new list
    mv "$BLOCKLIST_DIR/domains.txt.new" "$BLOCKLIST_DIR/domains.txt"
    
    # Trigger firewall rule update
    /etc/cron.daily/torrent-block-iptables 2>/dev/null || true
    /etc/cron.daily/torrent-block-nftables 2>/dev/null || true
    
    echo "[$(date)] Blocklist updated successfully" >> "$BLOCKLIST_DIR/update.log"
else
    echo "[$(date)] Failed to download blocklist" >> "$BLOCKLIST_DIR/update.log"
fi
UPDATEEOF
    
    chmod +x "$INSTALL_DIR/update-blocklist.sh"
    
    # Create weekly update cron job
    cat > /etc/cron.weekly/torrent-blocklist-update <<'CRONEOF'
#!/bin/bash
/opt/torrent-blocking/update-blocklist.sh
CRONEOF
    
    chmod +x /etc/cron.weekly/torrent-blocklist-update
    
    print_success "Auto-update configured (weekly)"
}

# Create uninstall script
create_uninstall_script() {
    print_info "Creating uninstall script..."
    
    cat > "$INSTALL_DIR/uninstall.sh" <<'UNINSTALLEOF'
#!/bin/bash

echo "Uninstalling torrent blocking..."

# Remove cron jobs
rm -f /etc/cron.daily/torrent-block-iptables
rm -f /etc/cron.daily/torrent-block-nftables
rm -f /etc/cron.daily/torrent-blocking-stats
rm -f /etc/cron.weekly/torrent-blocklist-update

# Remove iptables rules
if command -v iptables &> /dev/null; then
    # This is a simplified removal - in production, use iptables-save/restore
    echo "Note: Manual iptables rule removal may be required"
fi

# Remove nftables rules
if command -v nft &> /dev/null; then
    nft delete table inet torrentblock 2>/dev/null || true
fi

# Restore hosts file
if [ -f /var/backups/torrent-blocking/hosts.original ]; then
    cp /var/backups/torrent-blocking/hosts.original /etc/hosts
    echo "Hosts file restored"
fi

# Remove installation directory
rm -rf /opt/torrent-blocking
rm -rf /etc/torrent-blocklists
rm -rf /var/log/torrent-blocking

echo "✅ Uninstall complete"
UNINSTALLEOF
    
    chmod +x "$INSTALL_DIR/uninstall.sh"
    print_success "Uninstall script created"
}

# Print installation summary
print_summary() {
    print_header "Installation Complete!"
    
    echo ""
    echo -e "${GREEN}Torrent & P2P Blocking has been successfully installed!${NC}"
    echo ""
    echo "Configuration:"
    echo "  Firewall:        $FIREWALL"
    echo "  Install Dir:     $INSTALL_DIR"
    echo "  Blocklist Dir:   $BLOCKLIST_DIR"
    echo "  Log Dir:         $LOG_DIR"
    echo "  Backup Dir:      $BACKUP_DIR"
    echo ""
    echo "Features Enabled:"
    echo "  ✅ Domain-level blocking"
    echo "  ✅ Port-level blocking"
    echo "  ✅ Hosts file blocking"
    echo "  ✅ Daily rule updates"
    echo "  ✅ Weekly blocklist updates"
    echo "  ✅ Monitoring and logging"
    echo ""
    echo "Useful Commands:"
    echo "  View stats:      $INSTALL_DIR/monitor-blocking.sh"
    echo "  Update lists:    $INSTALL_DIR/update-blocklist.sh"
    echo "  Uninstall:       sudo $INSTALL_DIR/uninstall.sh"
    echo ""
    echo "Log Files:"
    echo "  Stats:           $LOG_DIR/blocking-stats.txt"
    echo "  Updates:         $BLOCKLIST_DIR/update.log"
    echo ""
    print_success "Installation finished! Your server is now protected."
}

# Main installation flow
main() {
    print_header "Enhanced Torrent & P2P Blocking Installer"
    
    check_root
    detect_firewall
    create_directories
    backup_configs
    download_blocklists
    setup_hosts_blocking
    
    if [ "$FIREWALL" = "iptables" ]; then
        setup_iptables_blocking
    else
        setup_nftables_blocking
    fi
    
    setup_port_blocking
    setup_monitoring
    setup_auto_update
    create_uninstall_script
    print_summary
}

# Run main function
main
