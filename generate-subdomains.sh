#!/bin/bash

# Generate subdomains and TLD variations for enhanced blocking
# This script expands the domain list with common subdomains and TLD variations

echo "Generating subdomain and TLD variations..."

INPUT_FILE="domains"
OUTPUT_FILE="domains-expanded"

# Common subdomains to add
SUBDOMAINS=(
    "www"
    "api"
    "tracker"
    "torrent"
    "download"
    "stream"
    "proxy"
    "mirror"
    "cdn"
    "static"
    "images"
    "files"
    "upload"
    "search"
    "mobile"
    "app"
    "admin"
    "mail"
    "ftp"
)

# Common TLDs to add
TLDS=(
    "to"
    "xyz"
    "pw"
    "ru"
    "su"
    "me"
    "io"
    "link"
    "top"
    "club"
    "site"
    "online"
    "download"
    "stream"
    "watch"
    "film"
    "movie"
    "video"
    "show"
    "series"
    "cc"
    "ws"
    "biz"
    "info"
    "net"
    "org"
    "com"
)

> "$OUTPUT_FILE"

# Read original domains and expand them
while IFS= read -r domain; do
    # Skip empty lines
    [[ -z "$domain" ]] && continue
    
    # Add original domain
    echo "$domain" >> "$OUTPUT_FILE"
    
    # Extract base domain (remove www. if present)
    base_domain="${domain#www.}"
    
    # Add subdomain variations
    for subdomain in "${SUBDOMAINS[@]}"; do
        echo "${subdomain}.${base_domain}" >> "$OUTPUT_FILE"
    done
    
    # Add TLD variations (only for domains with single TLD)
    if [[ "$domain" =~ ^[^.]+\.[^.]+$ ]]; then
        domain_name="${domain%.*}"
        for tld in "${TLDS[@]}"; do
            echo "${domain_name}.${tld}" >> "$OUTPUT_FILE"
        done
    fi
done < "$INPUT_FILE"

# Remove duplicates and sort
sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"

echo "✅ Expansion complete!"
echo "Original domains: $(wc -l < "$INPUT_FILE")"
echo "Expanded domains: $(wc -l < "$OUTPUT_FILE")"
echo "Output saved to: $OUTPUT_FILE"
