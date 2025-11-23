#!/bin/bash

# Automatic blocklist update script
# Fetches fresh blocklists from multiple sources and merges them

BLOCKLIST_DIR="/etc/torrent-blocklists"
MERGED_LIST="$BLOCKLIST_DIR/merged-blocklist.txt"
BACKUP_DIR="$BLOCKLIST_DIR/backups"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

mkdir -p "$BLOCKLIST_DIR" "$BACKUP_DIR"

echo "Fetching torrent blocklists from multiple sources..."

# Backup current list
if [ -f "$MERGED_LIST" ]; then
    cp "$MERGED_LIST" "$BACKUP_DIR/blocklist_$TIMESTAMP.txt"
fi

# Create temporary file for merged list
TEMP_LIST=$(mktemp)

# Source 1: Original GitHub repo
echo "Fetching from GitHub..."
wget -q -O - https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/domains >> "$TEMP_LIST" 2>/dev/null

# Source 2: Pi-hole blocklists (torrent-related)
echo "Fetching from Pi-hole blocklists..."
# Add popular Pi-hole blocklists
PIHOLE_LISTS=(
    "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
    "https://sysctl.org/cameleon/hosts"
    "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
)

for list in "${PIHOLE_LISTS[@]}"; do
    wget -q -O - "$list" 2>/dev/null | grep -v '^#' | grep -v '^$' | awk '{print $2}' >> "$TEMP_LIST"
done

# Source 3: Firebog blocklists
echo "Fetching from Firebog..."
FIREBOG_LISTS=(
    "https://v.firebog.net/hosts/lists.php?type=tick"
)

for list in "${FIREBOG_LISTS[@]}"; do
    wget -q -O - "$list" 2>/dev/null | grep -v '^#' | grep -v '^$' >> "$TEMP_LIST"
done

# Source 4: Community blocklists
echo "Fetching from community sources..."
COMMUNITY_LISTS=(
    "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
    "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20of%20Dandelion%20Sprout%27s%20lists/AntiMalwareHosts.txt"
)

for list in "${COMMUNITY_LISTS[@]}"; do
    wget -q -O - "$list" 2>/dev/null | grep -v '^#' | grep -v '^$' | awk '{print $2}' >> "$TEMP_LIST"
done

# Clean and deduplicate
echo "Processing and deduplicating..."
sort -u "$TEMP_LIST" -o "$MERGED_LIST"

# Remove temporary file
rm "$TEMP_LIST"

# Count results
DOMAIN_COUNT=$(wc -l < "$MERGED_LIST")
echo "✅ Blocklist update complete!"
echo "Total unique domains: $DOMAIN_COUNT"
echo "Merged list saved to: $MERGED_LIST"

# Optional: Update system files
if [ -f "$MERGED_LIST" ]; then
    echo "Updating system blocklist..."
    cp "$MERGED_LIST" /etc/trackers
    
    # Regenerate hosts file
    if [ -f "$MERGED_LIST" ]; then
        > /etc/hosts.torrent-block
        while read -r domain; do
            echo "0.0.0.0 $domain" >> /etc/hosts.torrent-block
        done < "$MERGED_LIST"
        
        echo "Hosts file updated: /etc/hosts.torrent-block"
    fi
fi

# Log update
echo "[$(date)] Updated blocklist with $DOMAIN_COUNT domains" >> "$BLOCKLIST_DIR/update.log"
