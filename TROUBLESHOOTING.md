# 🔧 Troubleshooting Guide

## Installation Issues

### Error: "syntax error, unexpected string" (nftables)

**Cause:** nftables chain detection issue

**Solution:**
```bash
# Clean up and reinstall
sudo nft delete table inet torrentblock 2>/dev/null || true
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh)"
```

---

### Error: "Permission denied"

**Cause:** Not running with sudo

**Solution:**
```bash
sudo bash INSTALL.sh
# or
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh)"
```

---

### Error: "wget: command not found"

**Cause:** wget not installed

**Solution:**
```bash
sudo apt-get update
sudo apt-get install wget
# Then run installation again
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh)"
```

---

### Error: "No internet connection"

**Cause:** Network connectivity issue

**Solution:**
```bash
# Test connection
ping 8.8.8.8

# If it fails, check your network
ip addr show
ip route show

# Once fixed, run installation
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh)"
```

---

### Error: "Failed to download domains list"

**Cause:** GitHub connectivity or file not found

**Solution:**
```bash
# Test GitHub access
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/domains

# If it works, retry installation
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh)"
```

---

## Post-Installation Issues

### Blocking Not Working

**Check 1: Verify firewall is running**
```bash
# For iptables
sudo systemctl status iptables
sudo iptables -L -n | grep DROP | head -5

# For nftables
sudo systemctl status nftables
sudo nft list ruleset | grep drop | head -5
```

**Check 2: Verify blocklists are loaded**
```bash
wc -l /etc/torrent-blocklists/domains.txt
# Should show 4000+

wc -l /etc/torrent-blocklists/hosts.txt
# Should show 4000+
```

**Check 3: Test DNS blocking**
```bash
nslookup 1337x.com
# Should return 0.0.0.0 or timeout

nslookup google.com
# Should work normally
```

**Check 4: Check logs**
```bash
cat /var/log/torrent-blocking/blocking-stats.txt
tail -f /var/log/torrent-blocking/blocked-domains.log
```

---

### High CPU Usage

**Cause:** Too many firewall rules

**Solution 1: Use DNS blocking instead**
```bash
# DNS blocking is more efficient
grep "1337x" /etc/hosts
# Should return entries
```

**Solution 2: Reduce rule count**
```bash
# Use nftables instead of iptables (more efficient)
sudo nft list ruleset | wc -l
```

**Solution 3: Check for loops**
```bash
# Check cron jobs
sudo crontab -l
sudo ls -la /etc/cron.daily/ | grep torrent
```

---

### Disk Space Issues

**Check disk usage**
```bash
df -h
# Check if /var is full

du -sh /var/log/torrent-blocking/
# Check log size

du -sh /var/backups/torrent-blocking/
# Check backup size
```

**Solution: Clean old logs**
```bash
# Archive old logs
sudo gzip /var/log/torrent-blocking/*.log

# Or delete old logs
sudo rm -f /var/log/torrent-blocking/*.log.gz
```

---

### Memory Issues

**Check memory usage**
```bash
free -h
# Check available memory

ps aux | grep nft
# Check nftables process
```

**Solution: Restart services**
```bash
# For nftables
sudo systemctl restart nftables

# For iptables
sudo systemctl restart iptables
```

---

## Verification Commands

### Check Installation Status
```bash
# Verify directories exist
ls -la /opt/torrent-blocking/
ls -la /etc/torrent-blocklists/
ls -la /var/log/torrent-blocking/
ls -la /var/backups/torrent-blocking/
```

### Check Firewall Rules
```bash
# For iptables
sudo iptables -L -n | grep DROP | wc -l
# Should show 4000+

# For nftables
sudo nft list ruleset | grep drop | wc -l
# Should show 4000+
```

### Check Hosts File
```bash
grep "1337x" /etc/hosts
# Should return entries

wc -l /etc/hosts
# Should be larger than before
```

### Check Cron Jobs
```bash
sudo crontab -l
# Should show torrent-blocking jobs

sudo ls -la /etc/cron.daily/ | grep torrent
# Should show daily jobs

sudo ls -la /etc/cron.weekly/ | grep torrent
# Should show weekly jobs
```

### Check Logs
```bash
# Blocking statistics
cat /var/log/torrent-blocking/blocking-stats.txt

# Blocked attempts
tail -f /var/log/torrent-blocking/blocked-domains.log

# Update history
cat /etc/torrent-blocklists/update.log
```

---

## Uninstall Issues

### Can't Uninstall

**Solution:**
```bash
# Manual uninstall
sudo rm -rf /opt/torrent-blocking/
sudo rm -rf /etc/torrent-blocklists/
sudo rm -rf /var/log/torrent-blocking/

# Remove cron jobs
sudo rm -f /etc/cron.daily/torrent-block-*
sudo rm -f /etc/cron.weekly/torrent-blocklist-update

# Restore hosts file
sudo cp /var/backups/torrent-blocking/hosts.original /etc/hosts

# Remove firewall rules
sudo nft delete table inet torrentblock 2>/dev/null || true
sudo iptables -F 2>/dev/null || true
```

---

## Getting Help

### Check Documentation
- `README.md` - Main documentation
- `QUICK-START.md` - Quick installation
- `IMPROVEMENTS.md` - Advanced features
- `DEPLOYMENT-CHECKLIST.md` - Step-by-step guide

### Check Logs
```bash
# All logs
ls -la /var/log/torrent-blocking/

# View specific log
cat /var/log/torrent-blocking/blocking-stats.txt
```

### Run Verbose Installation
```bash
# See detailed output
sudo bash -x INSTALL.sh
```

### Check System Info
```bash
# OS info
cat /etc/os-release

# Kernel version
uname -a

# Firewall info
which nft
which iptables
```

---

## Common Solutions

### Solution 1: Reinstall
```bash
# Uninstall first
sudo /opt/torrent-blocking/uninstall.sh

# Then reinstall
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh)"
```

### Solution 2: Use Basic Installation
```bash
# If enhanced installation fails, try basic
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/btorrent.sh && chmod +x btorrent.sh && sudo bash btorrent.sh
```

### Solution 3: Manual Installation
```bash
# Download files manually
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/domains
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/Thosts

# Copy to system
sudo mkdir -p /etc/torrent-blocklists
sudo cp domains /etc/torrent-blocklists/domains.txt
sudo cp Thosts /etc/torrent-blocklists/hosts.txt

# Update hosts file
sudo cat /etc/torrent-blocklists/hosts.txt >> /etc/hosts
```

---

## Still Having Issues?

1. **Check logs first:**
   ```bash
   cat /var/log/torrent-blocking/blocking-stats.txt
   tail -f /var/log/torrent-blocking/blocked-domains.log
   ```

2. **Run verification:**
   ```bash
   nslookup 1337x.com
   sudo nft list ruleset | head -20
   ```

3. **Check system resources:**
   ```bash
   free -h
   df -h
   top -b -n 1 | head -20
   ```

4. **Review documentation:**
   - README.md
   - DEPLOYMENT-CHECKLIST.md
   - IMPROVEMENTS.md

---

**Last Updated:** 2025-11-23
**Status:** ✅ Ready to Help
