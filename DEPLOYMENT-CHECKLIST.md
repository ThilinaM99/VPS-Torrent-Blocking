# Deployment Checklist

## Pre-Installation Checklist

- [ ] **System Requirements Met**
  - [ ] Linux-based server (Ubuntu, Debian, CentOS, etc.)
  - [ ] Root or sudo access available
  - [ ] Internet connection working
  - [ ] wget or curl installed
  - [ ] iptables or nftables available

- [ ] **Backup Current Configuration**
  - [ ] Backup `/etc/hosts` file
  - [ ] Backup firewall rules
  - [ ] Document current network configuration
  - [ ] Note any custom firewall rules

- [ ] **Plan Installation**
  - [ ] Decide: Enhanced vs Basic installation
  - [ ] Choose firewall: iptables or nftables
  - [ ] Plan maintenance schedule
  - [ ] Identify admin email for alerts

- [ ] **Test Environment**
  - [ ] Test in non-production first (if possible)
  - [ ] Verify no critical services affected
  - [ ] Document baseline performance metrics

---

## Installation Checklist

### Enhanced Installation

- [ ] **Download Script**
  ```bash
  wget https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/install-enhanced.sh
  chmod +x install-enhanced.sh
  ```

- [ ] **Run Installation**
  ```bash
  sudo bash install-enhanced.sh
  ```

- [ ] **Monitor Installation**
  - [ ] Watch for any error messages
  - [ ] Note any warnings
  - [ ] Verify completion message

- [ ] **Verify Installation Completed**
  - [ ] Check exit code: `echo $?` (should be 0)
  - [ ] Verify directories created:
    - [ ] `/opt/torrent-blocking/` exists
    - [ ] `/etc/torrent-blocklists/` exists
    - [ ] `/var/log/torrent-blocking/` exists
    - [ ] `/var/backups/torrent-blocking/` exists

### Basic Installation (Choose One)

- [ ] **iptables Installation**
  ```bash
  wget https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/btorrent.sh
  chmod +x btorrent.sh
  sudo bash btorrent.sh
  ```

- [ ] **nftables Installation**
  ```bash
  wget https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/block-torrent-nftables.sh
  chmod +x block-torrent-nftables.sh
  sudo bash block-torrent-nftables.sh
  ```

---

## Post-Installation Verification

- [ ] **Check Firewall Rules**
  - [ ] iptables: `sudo iptables -L -n | grep DROP | wc -l`
  - [ ] nftables: `sudo nft list ruleset | grep drop | wc -l`
  - [ ] Should show multiple rules (100+)

- [ ] **Verify Blocklists Loaded**
  - [ ] Check domains file: `wc -l /etc/torrent-blocklists/domains.txt`
  - [ ] Should show 4,000+ domains
  - [ ] Check hosts file: `wc -l /etc/torrent-blocklists/hosts.txt`

- [ ] **Test DNS Blocking**
  ```bash
  nslookup 1337x.com
  # Should return 0.0.0.0 or timeout
  ```

- [ ] **Test Port Blocking**
  ```bash
  timeout 2 nc -zv example.com 6881
  # Should timeout (connection refused)
  ```

- [ ] **Check Logs Created**
  - [ ] `/var/log/torrent-blocking/blocking-stats.txt` exists
  - [ ] `/var/log/torrent-blocking/blocked-domains.log` exists
  - [ ] `/etc/torrent-blocklists/update.log` exists

- [ ] **Verify Cron Jobs**
  ```bash
  sudo crontab -l
  # Should show torrent-blocking jobs
  ```

---

## Configuration Verification

- [ ] **Hosts File Updated**
  ```bash
  grep "1337x" /etc/hosts
  # Should return entries
  ```

- [ ] **Firewall Service Running**
  ```bash
  sudo systemctl status iptables
  # or
  sudo systemctl status nftables
  ```

- [ ] **Backup Directory Populated**
  ```bash
  ls -la /var/backups/torrent-blocking/
  # Should show backup files
  ```

- [ ] **Installation Directory Populated**
  ```bash
  ls -la /opt/torrent-blocking/
  # Should show scripts and files
  ```

---

## Performance Baseline

- [ ] **Measure CPU Usage**
  ```bash
  top -b -n 1 | head -20
  # Note baseline CPU usage
  ```

- [ ] **Check Memory Usage**
  ```bash
  free -h
  # Note baseline memory
  ```

- [ ] **Monitor Network**
  ```bash
  netstat -an | wc -l
  # Note baseline connection count
  ```

- [ ] **DNS Query Performance**
  ```bash
  time nslookup google.com
  # Note query time
  ```

---

## Monitoring Setup

- [ ] **View Statistics**
  ```bash
  cat /var/log/torrent-blocking/blocking-stats.txt
  ```

- [ ] **Check Blocked Attempts**
  ```bash
  tail -f /var/log/torrent-blocking/blocked-domains.log
  ```

- [ ] **Review Update Log**
  ```bash
  cat /etc/torrent-blocklists/update.log
  ```

- [ ] **Setup Email Alerts** (if desired)
  - [ ] Configure email in monitoring scripts
  - [ ] Test email delivery

- [ ] **Schedule Log Review**
  - [ ] Weekly: Check blocking statistics
  - [ ] Monthly: Review new torrent sites
  - [ ] Quarterly: Performance review

---

## Testing Checklist

- [ ] **Test Legitimate Traffic**
  - [ ] Browse normal websites
  - [ ] Test email
  - [ ] Test file downloads (non-torrent)
  - [ ] Verify no false positives

- [ ] **Test Blocked Traffic**
  - [ ] Try accessing 1337x.com (should fail)
  - [ ] Try accessing The Pirate Bay (should fail)
  - [ ] Try accessing RARBG (should fail)
  - [ ] Try torrent port connections (should fail)

- [ ] **Test Firewall Rules**
  - [ ] Check iptables: `sudo iptables -L -n`
  - [ ] Check nftables: `sudo nft list ruleset`
  - [ ] Verify rules are persistent

- [ ] **Test Auto-Updates**
  - [ ] Manually trigger update: `sudo /opt/torrent-blocking/update-blocklist.sh`
  - [ ] Verify new blocklist downloaded
  - [ ] Check update log: `cat /etc/torrent-blocklists/update.log`

---

## Documentation

- [ ] **Document Installation**
  - [ ] Note installation date
  - [ ] Record installation method used
  - [ ] Document any custom configurations
  - [ ] Save installation output

- [ ] **Create Runbook**
  - [ ] Document how to update blocklists
  - [ ] Document how to check logs
  - [ ] Document how to uninstall
  - [ ] Document emergency procedures

- [ ] **Backup Documentation**
  - [ ] Save README.md
  - [ ] Save QUICK-START.md
  - [ ] Save IMPROVEMENTS.md
  - [ ] Save this checklist

---

## Maintenance Schedule

- [ ] **Daily**
  - [ ] Monitor system performance
  - [ ] Check for errors in logs

- [ ] **Weekly**
  - [ ] Review blocking statistics
  - [ ] Check update log
  - [ ] Verify firewall rules active

- [ ] **Monthly**
  - [ ] Review blocked domains
  - [ ] Identify new torrent sites
  - [ ] Update documentation
  - [ ] Performance review

- [ ] **Quarterly**
  - [ ] Full system audit
  - [ ] Test uninstall/reinstall
  - [ ] Review security settings
  - [ ] Plan upgrades

---

## Troubleshooting Checklist

If issues occur:

- [ ] **Check Logs First**
  ```bash
  cat /var/log/torrent-blocking/blocking-stats.txt
  tail -f /var/log/torrent-blocking/blocked-domains.log
  cat /etc/torrent-blocklists/update.log
  ```

- [ ] **Verify Firewall Running**
  ```bash
  sudo systemctl status iptables
  sudo systemctl status nftables
  ```

- [ ] **Check Firewall Rules**
  ```bash
  sudo iptables -L -n | head -20
  sudo nft list ruleset | head -20
  ```

- [ ] **Test Connectivity**
  ```bash
  ping 8.8.8.8
  nslookup google.com
  ```

- [ ] **Review System Resources**
  ```bash
  top -b -n 1 | head -20
  free -h
  df -h
  ```

- [ ] **Check Cron Jobs**
  ```bash
  sudo crontab -l
  sudo ls -la /etc/cron.daily/ | grep torrent
  sudo ls -la /etc/cron.weekly/ | grep torrent
  ```

---

## Uninstall Checklist (If Needed)

- [ ] **Backup Current Configuration**
  - [ ] Save logs: `/var/log/torrent-blocking/`
  - [ ] Save blocklists: `/etc/torrent-blocklists/`
  - [ ] Save backups: `/var/backups/torrent-blocking/`

- [ ] **Run Uninstall**
  ```bash
  sudo /opt/torrent-blocking/uninstall.sh
  # or
  sudo bash rollback-torrent-block.sh
  ```

- [ ] **Verify Removal**
  - [ ] Check `/opt/torrent-blocking/` removed
  - [ ] Check `/etc/torrent-blocklists/` removed
  - [ ] Check `/var/log/torrent-blocking/` removed
  - [ ] Check firewall rules removed
  - [ ] Check cron jobs removed

- [ ] **Restore Original Configuration**
  - [ ] Restore `/etc/hosts` from backup
  - [ ] Restore firewall rules from backup
  - [ ] Verify services running normally

---

## Sign-Off

- [ ] **Installation Completed By:** ___________________
- [ ] **Date:** ___________________
- [ ] **System:** ___________________
- [ ] **Installation Method:** ___________________
- [ ] **All Checks Passed:** ___________________
- [ ] **Notes:** ___________________

---

**Deployment Status:** ☐ Not Started  ☐ In Progress  ☐ Complete

**Last Updated:** 2025-11-23
