#!/bin/bash

# Monitoring and Logging for Blocked Torrent Traffic
# Tracks blocked attempts and generates reports

LOG_DIR="/var/log/torrent-blocking"
BLOCKED_LOG="$LOG_DIR/blocked-domains.log"
STATS_FILE="$LOG_DIR/blocking-stats.txt"
ALERT_EMAIL="admin@example.com"  # Change this to your email

# Create log directory
mkdir -p "$LOG_DIR"

echo "Setting up monitoring and logging..."

# Function to log blocked domain
log_blocked_domain() {
    local domain="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] Blocked: $domain" >> "$BLOCKED_LOG"
}

# Function to generate statistics
generate_stats() {
    echo "=== Torrent Blocking Statistics ===" > "$STATS_FILE"
    echo "Generated: $(date)" >> "$STATS_FILE"
    echo "" >> "$STATS_FILE"
    
    echo "Total blocked attempts: $(wc -l < "$BLOCKED_LOG")" >> "$STATS_FILE"
    echo "" >> "$STATS_FILE"
    
    echo "Top 10 blocked domains:" >> "$STATS_FILE"
    sort "$BLOCKED_LOG" | cut -d':' -f3 | sort | uniq -c | sort -rn | head -10 >> "$STATS_FILE"
    echo "" >> "$STATS_FILE"
    
    echo "Blocked by hour:" >> "$STATS_FILE"
    grep -o '\[.*\]' "$BLOCKED_LOG" | cut -d' ' -f2 | cut -d':' -f1 | sort | uniq -c >> "$STATS_FILE"
}

# Setup iptables logging (if using iptables)
if command -v iptables &> /dev/null; then
    echo "Setting up iptables logging..."
    
    # Create a logging chain
    iptables -N TORRENT_LOG 2>/dev/null || true
    iptables -A TORRENT_LOG -j LOG --log-prefix "TORRENT_BLOCKED: " --log-level 4
    iptables -A TORRENT_LOG -j DROP
    
    echo "✅ iptables logging configured"
fi

# Setup rsyslog to parse torrent logs
cat > /etc/rsyslog.d/torrent-blocking.conf <<'EOF'
# Log torrent blocking attempts
:msg, contains, "TORRENT_BLOCKED" /var/log/torrent-blocking/torrent-blocks.log
& stop
EOF

# Restart rsyslog
systemctl restart rsyslog 2>/dev/null || service rsyslog restart 2>/dev/null

# Setup daily cron job for statistics
cat > /etc/cron.daily/torrent-blocking-stats <<'EOF'
#!/bin/bash
LOG_DIR="/var/log/torrent-blocking"
STATS_FILE="$LOG_DIR/blocking-stats.txt"
BLOCKED_LOG="$LOG_DIR/blocked-domains.log"

echo "=== Torrent Blocking Statistics ===" > "$STATS_FILE"
echo "Generated: $(date)" >> "$STATS_FILE"
echo "" >> "$STATS_FILE"

if [ -f "$BLOCKED_LOG" ]; then
    echo "Total blocked attempts: $(wc -l < "$BLOCKED_LOG")" >> "$STATS_FILE"
    echo "" >> "$STATS_FILE"
    
    echo "Top 10 blocked domains:" >> "$STATS_FILE"
    cut -d':' -f3 "$BLOCKED_LOG" | sort | uniq -c | sort -rn | head -10 >> "$STATS_FILE"
    echo "" >> "$STATS_FILE"
    
    echo "Blocked by hour:" >> "$STATS_FILE"
    grep -o '\[.*\]' "$BLOCKED_LOG" | cut -d' ' -f2 | cut -d':' -f1 | sort | uniq -c >> "$STATS_FILE"
fi

# Optional: Send email alert if too many blocks
BLOCK_COUNT=$(wc -l < "$BLOCKED_LOG" 2>/dev/null || echo 0)
if [ "$BLOCK_COUNT" -gt 1000 ]; then
    echo "High number of blocked attempts detected: $BLOCK_COUNT" | \
    mail -s "Torrent Blocking Alert" admin@example.com
fi
EOF

chmod +x /etc/cron.daily/torrent-blocking-stats

echo "✅ Monitoring and logging setup complete!"
echo "Logs will be saved to: $LOG_DIR"
echo "Daily statistics will be generated in: $STATS_FILE"
