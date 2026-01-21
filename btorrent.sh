#!/bin/bash
#
# Credit to original author: sam https://github.com/nikzad-avasam/block-torrent-on-server
# GitHub:   https://github.com/nikzad-avasam/block-torrent-on-server
# Author:   sam nikzad

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

if ! command -v iptables &> /dev/null; then
    echo "iptables not found. Please install iptables and retry." >&2
    exit 1
fi

if ! command -v wget &> /dev/null; then
    echo "wget not found. Please install wget and retry." >&2
    exit 1
fi

echo "Blocking all torrent traffic on your server. Please wait..."
wget -q -O /etc/trackers https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/domains
if [ ! -s /etc/trackers ]; then
    echo "Failed to download tracker list." >&2
    exit 1
fi
cat >/etc/cron.daily/denypublic<<'EOF'
IFS=$'\n'
L=$(/usr/bin/sort /etc/trackers | /usr/bin/uniq)
for fn in $L; do
        /sbin/iptables -D INPUT -d $fn -j DROP
        /sbin/iptables -D FORWARD -d $fn -j DROP
        /sbin/iptables -D OUTPUT -d $fn -j DROP
        /sbin/iptables -A INPUT -d $fn -j DROP
        /sbin/iptables -A FORWARD -d $fn -j DROP
        /sbin/iptables -A OUTPUT -d $fn -j DROP
done
EOF
chmod +x /etc/cron.daily/denypublic
/etc/cron.daily/denypublic

wget -q -O /tmp/Thosts https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/Thosts
if [ -s /tmp/Thosts ]; then
    cat /etc/hosts /tmp/Thosts | sort -u > /etc/hosts.uniq && mv /etc/hosts{.uniq,}
    rm -f /tmp/Thosts
fi

echo "✅ Torrent blocking rules installed."
