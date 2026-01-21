#!/bin/bash

# Block common BitTorrent ports
# This prevents torrent traffic on known ports regardless of domain

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

if ! command -v iptables &> /dev/null && ! command -v nft &> /dev/null; then
    echo "Neither iptables nor nftables found. Please install one and retry." >&2
    exit 1
fi

echo "Blocking BitTorrent ports..."

# Common BitTorrent ports
TORRENT_PORTS=(
    6881 6882 6883 6884 6885 6886 6887 6888 6889  # Default DHT ports
    6969                                           # BitTorrent tracker
    51413                                          # Transmission default
    6881:6889                                      # Range
    51413:51413                                    # Transmission range
    4662 4672                                      # eMule/eDonkey
    3074 3478 3479 3480                           # Xbox Live
    1214                                           # Kazaa
    5190                                           # AIM/ICQ
    7680 7681                                      # Pando
)

# Using iptables (if available)
if command -v iptables &> /dev/null; then
    echo "Setting up iptables rules..."
    
    for port in "${TORRENT_PORTS[@]}"; do
        # Block incoming
        iptables -D INPUT -p tcp --dport "$port" -j DROP 2>/dev/null
        iptables -D INPUT -p udp --dport "$port" -j DROP 2>/dev/null
        iptables -A INPUT -p tcp --dport "$port" -j DROP
        iptables -A INPUT -p udp --dport "$port" -j DROP
        
        # Block outgoing
        iptables -D OUTPUT -p tcp --dport "$port" -j DROP 2>/dev/null
        iptables -D OUTPUT -p udp --dport "$port" -j DROP 2>/dev/null
        iptables -A OUTPUT -p tcp --dport "$port" -j DROP
        iptables -A OUTPUT -p udp --dport "$port" -j DROP
    done
    
    echo "✅ iptables rules applied"
fi

# Using nftables (if available)
if command -v nft &> /dev/null; then
    echo "Setting up nftables rules..."
    
    # Create table and chain if not exists
    nft list tables | grep -q 'torrentblock' || nft add table inet torrentblock
    if ! nft list chains inet torrentblock 2>/dev/null | grep -q 'portblock'; then
        nft add chain inet torrentblock portblock { type filter hook output priority 0 \; }
    fi
    
    # Flush old rules
    nft flush chain inet torrentblock portblock
    
    # Add port blocking rules
    for port in "${TORRENT_PORTS[@]}"; do
        nft add rule inet torrentblock portblock tcp dport "$port" drop
        nft add rule inet torrentblock portblock udp dport "$port" drop
    done
    
    echo "✅ nftables rules applied"
fi

echo "✅ BitTorrent port blocking complete!"
