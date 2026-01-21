#!/bin/bash

# Credit to original author: sam
# Converted to nftables by: ThilinaM99
# GitHub: https://github.com/nikzad-avasam/block-torrent-on-server

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

if ! command -v nft &> /dev/null; then
    echo "nftables not found. Please install nftables and retry." >&2
    exit 1
fi

if ! command -v wget &> /dev/null; then
    echo "wget not found. Please install wget and retry." >&2
    exit 1
fi

if ! command -v getent &> /dev/null; then
    echo "getent not found. Please install libc-bin and retry." >&2
    exit 1
fi

echo "Blocking all torrent traffic using nftables. Please wait..."

# Download tracker domains list
wget -q -O /etc/trackers https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/domains
if [ ! -s /etc/trackers ]; then
    echo "Failed to download tracker list." >&2
    exit 1
fi

# Create nftables table and set if not already present
nft list tables | grep -q 'torrentblock' || nft add table inet torrentblock
if ! nft list chains inet torrentblock 2>/dev/null | grep -q 'trackerblock'; then
    nft add chain inet torrentblock trackerblock { type filter hook output priority 0 \; }
fi

# Clean old rules
nft flush chain inet torrentblock trackerblock

# Add new blocking rules
while read -r domain; do
    ip=$(getent ahosts "$domain" | awk '$1 ~ /^[0-9.]+$/ {print $1; exit}')
    if [[ -n "$ip" ]]; then
        nft add rule inet torrentblock trackerblock ip daddr "$ip" drop
    fi
done < <(sort -u /etc/trackers)

# Setup daily cron job to refresh tracker IPs
cat >/etc/cron.daily/nft-torrent-block<<'EOF'
#!/bin/bash
wget -q -O /etc/trackers https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/domains
if [ ! -s /etc/trackers ]; then
    exit 1
fi
nft flush chain inet torrentblock trackerblock
while read -r domain; do
    ip=$(getent ahosts "$domain" | awk '$1 ~ /^[0-9.]+$/ {print $1; exit}')
    if [[ -n "$ip" ]]; then
        nft add rule inet torrentblock trackerblock ip daddr "$ip" drop
    fi
done < <(sort -u /etc/trackers)
EOF

chmod +x /etc/cron.daily/nft-torrent-block

# Optional: Update /etc/hosts to block domains at resolution level
wget -q -O /tmp/Thosts https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/Thosts
if [ -s /tmp/Thosts ]; then
    cat /etc/hosts /tmp/Thosts | sort -u > /etc/hosts.uniq && mv /etc/hosts{.uniq,}
    rm -f /tmp/Thosts
fi

echo "✅ Torrent traffic blocking via nftables is now active."
