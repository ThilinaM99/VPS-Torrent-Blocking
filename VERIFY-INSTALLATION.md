# ✅ Verify Installation is Working

After running the installation, use these commands to verify everything is working correctly.

---

## 🔍 Quick Verification

### 1. Check Installation Directories
```bash
# Verify all directories were created
ls -la /opt/torrent-blocking/
ls -la /etc/torrent-blocklists/
ls -la /var/log/torrent-blocking/
ls -la /var/backups/torrent-blocking/
```

**Expected:** All directories should exist with proper files

---

### 2. Check Blocking Statistics
```bash
cat /var/log/torrent-blocking/blocking-stats.txt
```

**Expected:** Should show blocking statistics and configuration

---

### 3. Check Firewall Rules

#### For nftables:
```bash
sudo nft list ruleset | grep torrentblock
```

**Expected:** Should show rules for `domainblock` and `portblock` chains

#### For iptables:
```bash
sudo iptables -L -n | grep DROP | head -10
```

**Expected:** Should show DROP rules for torrent ports

---

### 4. Test DNS Blocking
```bash
# Test a blocked domain
nslookup 1337x.com
# Should return 0.0.0.0 or timeout

# Test a normal domain (should work)
nslookup google.com
# Should return normal IP address
```

**Expected:** Blocked domains return 0.0.0.0, normal domains work fine

---

### 5. Check Hosts File
```bash
# Verify hosts file was updated
grep "1337x" /etc/hosts
# Should return entries like: 0.0.0.0 1337x.com

# Count total entries
wc -l /etc/hosts
# Should be much larger than before installation
```

**Expected:** Hosts file contains 4,472+ torrent domain entries

---

### 6. Check Blocklist Files
```bash
# Check domains list
wc -l /etc/torrent-blocklists/domains.txt
# Should show 4472 or more

# Check hosts file
wc -l /etc/torrent-blocklists/hosts.txt
# Should show 4472 or more
```

**Expected:** Both files should contain 4,472+ entries

---

### 7. Check Cron Jobs
```bash
# View scheduled cron jobs
sudo crontab -l

# Check daily cron jobs
ls -la /etc/cron.daily/ | grep torrent

# Check weekly cron jobs
ls -la /etc/cron.weekly/ | grep torrent
```

**Expected:** Should show daily and weekly torrent blocking jobs

---

### 8. Check Monitoring Script
```bash
# Run the monitoring script
sudo /opt/torrent-blocking/monitor-blocking.sh

# View the output
cat /var/log/torrent-blocking/blocking-stats.txt
```

**Expected:** Should show blocking statistics and configuration details

---

## 📊 Full Verification Script

Run this complete verification:

```bash
#!/bin/bash

echo "========================================="
echo "Torrent Blocking Installation Verification"
echo "========================================="
echo ""

# Check directories
echo "1. Checking directories..."
for dir in /opt/torrent-blocking /etc/torrent-blocklists /var/log/torrent-blocking /var/backups/torrent-blocking; do
    if [ -d "$dir" ]; then
        echo "   ✅ $dir exists"
    else
        echo "   ❌ $dir missing"
    fi
done
echo ""

# Check files
echo "2. Checking blocklist files..."
if [ -f /etc/torrent-blocklists/domains.txt ]; then
    count=$(wc -l < /etc/torrent-blocklists/domains.txt)
    echo "   ✅ domains.txt exists ($count entries)"
else
    echo "   ❌ domains.txt missing"
fi

if [ -f /etc/torrent-blocklists/hosts.txt ]; then
    count=$(wc -l < /etc/torrent-blocklists/hosts.txt)
    echo "   ✅ hosts.txt exists ($count entries)"
else
    echo "   ❌ hosts.txt missing"
fi
echo ""

# Check firewall
echo "3. Checking firewall configuration..."
if command -v nft &> /dev/null; then
    if sudo nft list ruleset 2>/dev/null | grep -q torrentblock; then
        echo "   ✅ nftables rules configured"
    else
        echo "   ❌ nftables rules not found"
    fi
elif command -v iptables &> /dev/null; then
    if sudo iptables -L -n 2>/dev/null | grep -q DROP; then
        echo "   ✅ iptables rules configured"
    else
        echo "   ❌ iptables rules not found"
    fi
else
    echo "   ❌ No firewall found"
fi
echo ""

# Check hosts file
echo "4. Checking hosts file..."
if grep -q "1337x" /etc/hosts; then
    count=$(grep -c "0.0.0.0" /etc/hosts)
    echo "   ✅ Hosts file updated ($count entries)"
else
    echo "   ❌ Hosts file not updated"
fi
echo ""

# Check cron jobs
echo "5. Checking cron jobs..."
if [ -f /etc/cron.daily/torrent-block-nftables ] || [ -f /etc/cron.daily/torrent-block-iptables ]; then
    echo "   ✅ Daily cron job configured"
else
    echo "   ❌ Daily cron job not found"
fi

if [ -f /etc/cron.weekly/torrent-blocklist-update ]; then
    echo "   ✅ Weekly cron job configured"
else
    echo "   ❌ Weekly cron job not found"
fi
echo ""

# Check DNS blocking
echo "6. Testing DNS blocking..."
if nslookup 1337x.com 2>/dev/null | grep -q "0.0.0.0"; then
    echo "   ✅ DNS blocking working (1337x.com blocked)"
else
    echo "   ⚠️  DNS blocking may not be working"
fi

if nslookup google.com 2>/dev/null | grep -q "142.251"; then
    echo "   ✅ Normal DNS working (google.com resolves)"
else
    echo "   ⚠️  Normal DNS may not be working"
fi
echo ""

echo "========================================="
echo "Verification Complete!"
echo "========================================="
```

Save this as `verify.sh` and run:
```bash
chmod +x verify.sh
sudo bash verify.sh
```

---

## 🎯 Expected Results

After successful installation, you should see:

✅ All 4 directories created
✅ Blocklist files with 4,472+ entries
✅ Firewall rules configured (nftables or iptables)
✅ Hosts file updated with torrent domains
✅ Cron jobs scheduled for daily/weekly updates
✅ DNS blocking working (blocked domains return 0.0.0.0)
✅ Normal DNS working (legitimate domains resolve)

---

## 🔧 Troubleshooting

### If DNS blocking isn't working:
```bash
# Check if hosts file was updated
grep "1337x" /etc/hosts

# Flush DNS cache
sudo systemctl restart systemd-resolved
# or
sudo /etc/init.d/nscd restart
```

### If firewall rules aren't showing:
```bash
# For nftables
sudo nft list ruleset

# For iptables
sudo iptables -L -n
```

### If cron jobs aren't running:
```bash
# Check cron logs
sudo grep CRON /var/log/syslog | tail -20

# Check if cron service is running
sudo systemctl status cron
```

### If blocklist files are missing:
```bash
# Re-download manually
sudo mkdir -p /etc/torrent-blocklists
sudo wget -O /etc/torrent-blocklists/domains.txt https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/domains
sudo wget -O /etc/torrent-blocklists/hosts.txt https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/Thosts
```

---

## 📝 Log Files to Check

```bash
# View blocking statistics
cat /var/log/torrent-blocking/blocking-stats.txt

# View blocked domain attempts
tail -f /var/log/torrent-blocking/blocked-domains.log

# View update history
cat /etc/torrent-blocklists/update.log

# View system logs for cron jobs
sudo grep torrent /var/log/syslog | tail -20
```

---

## ✅ Installation Success Indicators

Your installation is successful if:

1. ✅ All directories exist
2. ✅ Blocklist files are present with 4,472+ entries
3. ✅ Firewall rules are configured
4. ✅ Hosts file is updated
5. ✅ Cron jobs are scheduled
6. ✅ DNS blocking works (test with `nslookup 1337x.com`)
7. ✅ Normal DNS works (test with `nslookup google.com`)
8. ✅ Monitoring script runs without errors

---

## 🚀 Next Steps

After verification:

1. **Monitor blocking:** `tail -f /var/log/torrent-blocking/blocked-domains.log`
2. **Check statistics:** `cat /var/log/torrent-blocking/blocking-stats.txt`
3. **Update lists manually:** `sudo /opt/torrent-blocking/update-blocklist.sh`
4. **View firewall rules:** `sudo nft list ruleset` or `sudo iptables -L -n`

---

**Status:** ✅ **Ready to Verify**

Use these commands to confirm your installation is working correctly!

---

**Last Updated:** 2025-11-23
