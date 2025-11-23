# Quick Start Guide

## 🚀 Installation in 30 Seconds

### Recommended: Enhanced Installation
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/install-enhanced.sh && chmod +x install-enhanced.sh && sudo bash install-enhanced.sh
```

That's it! The script will:
- ✅ Detect your firewall (iptables/nftables)
- ✅ Download latest blocklists
- ✅ Setup domain blocking
- ✅ Setup port blocking
- ✅ Configure monitoring
- ✅ Setup auto-updates
- ✅ Create backups

---

## 📋 What Happens During Installation

1. **Root Check** - Verifies you have sudo access
2. **Firewall Detection** - Checks for iptables or nftables
3. **Directory Creation** - Creates necessary folders
4. **Backup** - Backs up your current configuration
5. **Download** - Gets latest blocklists
6. **Blocking Setup** - Configures firewall rules
7. **Monitoring** - Sets up logging and stats
8. **Auto-Update** - Schedules weekly updates
9. **Summary** - Shows installation details

---

## ✅ Verify Installation

Check if blocking is working:

```bash
# View blocking statistics
cat /var/log/torrent-blocking/blocking-stats.txt

# Check active rules
sudo iptables -L -n | grep DROP

# Or for nftables
sudo nft list ruleset | grep drop

# Test domain blocking
nslookup 1337x.com
# Should return 0.0.0.0 or timeout
```

---

## 🔧 Common Commands

### View Statistics
```bash
/opt/torrent-blocking/monitor-blocking.sh
```

### Update Blocklists Manually
```bash
sudo /opt/torrent-blocking/update-blocklist.sh
```

### View Logs
```bash
# Daily statistics
cat /var/log/torrent-blocking/blocking-stats.txt

# Update history
cat /etc/torrent-blocklists/update.log

# Blocked attempts
tail -f /var/log/torrent-blocking/blocked-domains.log
```

### Uninstall
```bash
sudo /opt/torrent-blocking/uninstall.sh
```

---

## 🎯 Installation Options

### Option 1: Enhanced (Recommended)
**Best for:** Production servers, VPS with monitoring needs
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/install-enhanced.sh && chmod +x install-enhanced.sh && sudo bash install-enhanced.sh
```

### Option 2: Basic (iptables)
**Best for:** Simple setups, older systems
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/btorrent.sh && chmod +x btorrent.sh && sudo bash btorrent.sh
```

### Option 3: Basic (nftables)
**Best for:** Modern systems with nftables
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/block-torrent-nftables.sh && chmod +x block-torrent-nftables.sh && sudo bash block-torrent-nftables.sh
```

---

## ⚠️ Important Notes

1. **Root Access Required**
   - Use `sudo` for all commands
   - Installation requires root privileges

2. **Backup Your Config**
   - Automatic backups are created
   - Located in `/var/backups/torrent-blocking/`

3. **Test First**
   - Test in non-production environment if possible
   - Monitor logs after installation

4. **Keep Updated**
   - Blocklists update weekly automatically
   - Check logs monthly for new torrent sites

---

## 🐛 Troubleshooting

### Installation Fails
```bash
# Check if you have sudo access
sudo whoami
# Should output: root

# Check internet connection
ping 8.8.8.8

# Check if wget is installed
which wget
```

### Blocking Not Working
```bash
# Verify firewall is running
sudo systemctl status iptables
# or
sudo systemctl status nftables

# Check if rules are loaded
sudo iptables -L -n | head -20
# or
sudo nft list ruleset | head -20
```

### High CPU Usage
- Use nftables instead of iptables
- Reduce rule count with DNS blocking
- Check logs for excessive blocks

---

## 📊 What Gets Blocked

✅ **Torrent Trackers**
- 1337x, The Pirate Bay, RARBG, YTS, EZTV, etc.

✅ **P2P Networks**
- BitTorrent, DHT, Magnet links

✅ **Torrent Ports**
- 6881-6889, 6969, 51413, 4662, 4672

✅ **Streaming Sites**
- Movie/TV streaming platforms

✅ **File Sharing**
- MEGA, Mediafire, and similar services

---

## 📞 Support

**Issues?**
1. Check logs: `/var/log/torrent-blocking/`
2. Review IMPROVEMENTS.md for advanced options
3. Check original repo: https://github.com/nikzad-avasam/block-torrent-on-server

---

## 🎓 Learn More

- **IMPROVEMENTS.md** - Advanced features and scripts
- **README.md** - Complete documentation
- **QUICK-START.md** - This file

---

**Ready to install?**

```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/install-enhanced.sh && chmod +x install-enhanced.sh && sudo bash install-enhanced.sh
```

💚 Stay safe!
