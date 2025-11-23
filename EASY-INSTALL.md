# 🚀 Easy Installation - Copy & Paste

## ⚡ Fastest Way to Install (One Command)

### For Ubuntu/Debian VPS

Copy and paste this entire command in your terminal:

```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh)"
```

**That's it!** The script will:
- ✅ Check dependencies (wget, etc.)
- ✅ Download the enhanced installer
- ✅ Run the full installation (takes ~1 minute)
- ✅ Clean up temporary files
- ✅ Show completion status and next steps

**Installation time:** ~1 minute (much faster than before!)

---

## 📋 Alternative Methods

### Method 1: Download and Run
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh
sudo bash INSTALL.sh
```

### Method 2: Using curl
```bash
curl -fsSL https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh | sudo bash
```

### Method 3: Direct Enhanced Installation
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/install-enhanced.sh && chmod +x install-enhanced.sh && sudo bash install-enhanced.sh
```

### Method 4: Basic Installation (iptables)
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/btorrent.sh && chmod +x btorrent.sh && sudo bash btorrent.sh
```

### Method 5: Basic Installation (nftables)
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/block-torrent-nftables.sh && chmod +x block-torrent-nftables.sh && sudo bash block-torrent-nftables.sh
```

---

## ✅ What Happens During Installation

1. **Root Check** - Verifies you have sudo access
2. **Internet Check** - Confirms connection to GitHub
3. **Dependencies** - Installs wget if needed
4. **Download** - Gets the enhanced installer
5. **Installation** - Runs the full setup
6. **Cleanup** - Removes temporary files
7. **Summary** - Shows completion status

---

## 🎯 After Installation

### View Statistics
```bash
cat /var/log/torrent-blocking/blocking-stats.txt
```

### Monitor Blocked Attempts
```bash
tail -f /var/log/torrent-blocking/blocked-domains.log
```

### Check Update Log
```bash
cat /etc/torrent-blocklists/update.log
```

### Update Blocklists Manually
```bash
sudo /opt/torrent-blocking/update-blocklist.sh
```

### Uninstall
```bash
sudo /opt/torrent-blocking/uninstall.sh
```

---

## 🐛 Troubleshooting

### "Permission denied" error
```bash
# Make sure you use sudo
sudo bash INSTALL.sh
```

### "wget: command not found"
```bash
# Install wget first
sudo apt-get update
sudo apt-get install wget
# Then run installation
sudo bash INSTALL.sh
```

### "No internet connection"
```bash
# Check your connection
ping 8.8.8.8
# If it fails, fix your network first
```

### Installation fails
```bash
# Check if you have enough disk space
df -h

# Check if you have enough memory
free -h

# Try running with verbose output
sudo bash -x INSTALL.sh
```

---

## 📊 Installation Options Comparison

| Option | Command | Best For | Time |
|--------|---------|----------|------|
| **Easiest** | One-liner with curl | Quick setup | 2 min |
| **Enhanced** | Direct enhanced script | Full features | 3 min |
| **Basic (iptables)** | Basic iptables | Simple setup | 1 min |
| **Basic (nftables)** | Basic nftables | Modern systems | 1 min |

---

## 🎓 Recommended Installation

### For Most Users (Ubuntu/Debian VPS)
```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh)"
```

### For Advanced Users
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/install-enhanced.sh && chmod +x install-enhanced.sh && sudo bash install-enhanced.sh
```

### For Minimal Setup
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/btorrent.sh && chmod +x btorrent.sh && sudo bash btorrent.sh
```

---

## ✨ Features Installed

✅ **Domain Blocking** - 4,472+ blocked domains
✅ **Port Blocking** - BitTorrent ports (6881-6889, 6969, 51413)
✅ **Monitoring** - Real-time logging and statistics
✅ **Auto-Updates** - Weekly blocklist updates
✅ **Automatic Backups** - All configurations backed up
✅ **Easy Uninstall** - One-command removal
✅ **Firewall Detection** - Auto-detects iptables/nftables

---

## 💡 Pro Tips

1. **Test First** - Run in non-production environment first
2. **Monitor Logs** - Check logs weekly for new torrent sites
3. **Keep Updated** - Blocklists update automatically weekly
4. **Backup Config** - Automatic backups are created
5. **Easy Removal** - Can be uninstalled anytime

---

## 🛡️ Security

✅ Automatic backups of all configurations
✅ Non-destructive installation
✅ Easy rollback/uninstall
✅ Comprehensive logging
✅ Regular blocklist updates
✅ Email alert system (optional)

---

## 📞 Support

**Need Help?**
- Check logs: `/var/log/torrent-blocking/`
- Read: `README.md` on GitHub
- Review: `DEPLOYMENT-CHECKLIST.md`

**GitHub:** https://github.com/ThilinaM99/VPS-Torrent-Blocking

---

## 🎉 Ready?

### Copy and Paste This:
```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh)"
```

That's all you need! Your VPS will be protected in 2-3 minutes.

---

**Last Updated:** 2025-11-23
**Status:** ✅ Ready to Use
