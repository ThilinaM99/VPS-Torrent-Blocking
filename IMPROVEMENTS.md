# Torrent Blocking Improvements

This document outlines the new scripts and improvements added to enhance torrent blocking on your server.

## New Scripts

### 1. **generate-subdomains.sh**
Expands your domain blocklist with subdomain and TLD variations.

**What it does:**
- Generates common subdomains (www, api, tracker, proxy, mirror, cdn, etc.)
- Adds TLD variations (.to, .xyz, .pw, .ru, .su, .me, .io, etc.)
- Removes duplicates and sorts the output
- Increases blocking coverage significantly

**Usage:**
```bash
chmod +x generate-subdomains.sh
./generate-subdomains.sh
```

**Output:** `domains-expanded` file with 10-50x more domains

---

### 2. **port-blocking.sh**
Blocks common BitTorrent ports at the firewall level.

**What it does:**
- Blocks DHT ports (6881-6889)
- Blocks BitTorrent tracker port (6969)
- Blocks common P2P application ports
- Works with both iptables and nftables
- Blocks both incoming and outgoing traffic

**Usage:**
```bash
chmod +x port-blocking.sh
sudo ./port-blocking.sh
```

**Ports blocked:**
- 6881-6889 (DHT)
- 6969 (BitTorrent tracker)
- 51413 (Transmission)
- 4662, 4672 (eMule/eDonkey)
- And more...

---

### 3. **auto-update-blocklist.sh**
Automatically fetches and merges blocklists from multiple sources.

**What it does:**
- Fetches from GitHub repository
- Integrates Pi-hole blocklists
- Adds Firebog community lists
- Merges and deduplicates all sources
- Maintains backups of previous lists
- Logs all updates

**Usage:**
```bash
chmod +x auto-update-blocklist.sh
sudo ./auto-update-blocklist.sh
```

**Setup as daily cron job:**
```bash
echo "0 2 * * * /path/to/auto-update-blocklist.sh" | sudo crontab -
```

---

### 4. **monitoring-logging.sh**
Sets up comprehensive logging and monitoring of blocked traffic.

**What it does:**
- Creates logging infrastructure
- Tracks blocked domain attempts
- Generates daily statistics reports
- Sends email alerts for high block counts
- Integrates with rsyslog for centralized logging

**Usage:**
```bash
chmod +x monitoring-logging.sh
sudo ./monitoring-logging.sh
```

**Log files created:**
- `/var/log/torrent-blocking/blocked-domains.log` - All blocked attempts
- `/var/log/torrent-blocking/blocking-stats.txt` - Daily statistics
- `/var/log/torrent-blocking/torrent-blocks.log` - iptables logs

---

### 5. **dnsmasq-config.conf**
Configuration file for DNSmasq DNS-level blocking.

**What it does:**
- Blocks domains at DNS resolution level
- More efficient than firewall rules
- Returns 0.0.0.0 for blocked domains
- Reduces bandwidth usage

**Installation:**
```bash
# Copy to dnsmasq configuration
sudo cp dnsmasq-config.conf /etc/dnsmasq.d/torrent-blocking.conf

# Restart dnsmasq
sudo systemctl restart dnsmasq
```

---

## Implementation Strategy

### Phase 1: Basic Setup (Recommended First)
1. Run existing `btorrent.sh` or `block-torrent-nftables.sh`
2. Run `port-blocking.sh` for port-level blocking
3. Run `monitoring-logging.sh` for visibility

### Phase 2: Enhanced Blocking
1. Run `generate-subdomains.sh` to expand domain list
2. Update system files with expanded list
3. Test blocking effectiveness

### Phase 3: Automation
1. Setup `auto-update-blocklist.sh` as daily cron job
2. Configure dnsmasq for DNS-level blocking
3. Monitor logs regularly

---

## Testing Blocking

### Test DNS blocking:
```bash
nslookup 1337x.com
# Should return 0.0.0.0 or timeout
```

### Test port blocking:
```bash
# Try to connect to blocked port (should timeout)
timeout 2 nc -zv example.com 6881
```

### Check active rules:
```bash
# For iptables
sudo iptables -L -n | grep DROP

# For nftables
sudo nft list ruleset
```

### Monitor logs:
```bash
tail -f /var/log/torrent-blocking/blocked-domains.log
tail -f /var/log/torrent-blocking/blocking-stats.txt
```

---

## Performance Considerations

| Method | Performance | Coverage | Maintenance |
|--------|-------------|----------|-------------|
| Domain blocking (hosts) | Medium | Good | Low |
| iptables rules | High | Good | Medium |
| nftables rules | Very High | Good | Medium |
| DNS blocking (dnsmasq) | Very High | Excellent | Low |
| Port blocking | Very High | Fair | Low |

---

## Recommended Configuration

For optimal blocking with minimal performance impact:

1. **DNS Level** (Primary)
   - Use dnsmasq with full blocklist
   - Lowest overhead, highest efficiency

2. **Port Level** (Secondary)
   - Block common torrent ports
   - Catches non-DNS torrent attempts

3. **Domain Level** (Tertiary)
   - iptables/nftables for critical domains
   - Backup if DNS fails

4. **Monitoring** (Always)
   - Track blocked attempts
   - Identify new torrent sites
   - Generate reports

---

## Troubleshooting

### High CPU usage from rules
- Use nftables instead of iptables
- Reduce rule count with DNS blocking
- Use port blocking instead of domain blocking

### Legitimate sites blocked
- Check `/var/log/torrent-blocking/blocked-domains.log`
- Whitelist specific domains in firewall
- Adjust dnsmasq configuration

### Rules not applying
- Check if firewall service is running
- Verify rule syntax with `iptables -L` or `nft list`
- Check system logs: `journalctl -xe`

---

## Security Notes

⚠️ **Important:**
- These scripts require root/sudo access
- Test in non-production environment first
- Maintain backups of original configurations
- Monitor for false positives
- Keep blocklists updated regularly

---

## Support & Updates

For updates and improvements:
- Original repo: https://github.com/nikzad-avasam/block-torrent-on-server
- Check logs regularly for new torrent sites
- Update blocklists weekly or monthly
- Monitor performance metrics

---

**Last Updated:** 2025-11-23
