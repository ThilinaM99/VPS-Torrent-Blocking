# 🚀 START HERE - Block Torrent on Server

Welcome! This guide will get you started in **30 seconds**.

---

## ⚡ Quick Installation (Recommended)

Copy and paste this command in your terminal:

```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/install-enhanced.sh && chmod +x install-enhanced.sh && sudo bash install-enhanced.sh
```

That's it! The script will:
- ✅ Detect your firewall automatically (iptables/nftables)
- ✅ Download latest blocklists (4,472+ domains)
- ✅ Setup domain-level blocking (hosts file)
- ✅ Setup port-level blocking (BitTorrent ports)
- ✅ Configure monitoring & logging with stats
- ✅ Setup weekly auto-updates from multiple sources
- ✅ Create automatic backups of configurations

---

## ✅ Verify It's Working

After installation, run this to check:

```bash
cat /var/log/torrent-blocking/blocking-stats.txt
```

You should see blocking statistics!

---

## 📚 Documentation

| File | Purpose | Read Time |
|------|---------|-----------|
| **README.md** | Main documentation | 5 min |
| **QUICK-START.md** | Installation guide | 3 min |
| **IMPROVEMENTS.md** | Advanced features | 10 min |
| **DEPLOYMENT-CHECKLIST.md** | Step-by-step setup | 15 min |
| **INDEX.md** | Complete file guide | 5 min |

---

## 🎯 What Gets Blocked

✅ Torrent trackers (1337x, The Pirate Bay, RARBG, YTS, etc.)
✅ P2P networks (BitTorrent, DHT)
✅ Torrent ports (6881-6889, 6969, 51413)
✅ Streaming sites
✅ File sharing services

---

## 🔧 Useful Commands

```bash
# View statistics
cat /var/log/torrent-blocking/blocking-stats.txt

# View blocked attempts
tail -f /var/log/torrent-blocking/blocked-domains.log

# Update blocklists manually
sudo /opt/torrent-blocking/update-blocklist.sh

# Test if blocking works
nslookup 1337x.com
# Should return 0.0.0.0 or timeout

# Uninstall if needed
sudo /opt/torrent-blocking/uninstall.sh
```

---

## ❓ Common Questions

**Q: Do I need root access?**
A: Yes, use `sudo` for installation.

**Q: Which installation method should I use?**
A: Use `install-enhanced.sh` (recommended) for all features.

**Q: Can I uninstall later?**
A: Yes, just run `/opt/torrent-blocking/uninstall.sh`

**Q: Will it block legitimate traffic?**
A: No, it only blocks known torrent sites.

**Q: How often are blocklists updated?**
A: Weekly automatically (configurable).

---

## 🚨 Troubleshooting

**Installation failed?**
```bash
# Check if you have sudo access
sudo whoami
# Should output: root
```

**Blocking not working?**
```bash
# Check if firewall rules are active
sudo iptables -L -n | grep DROP
# or
sudo nft list ruleset | grep drop
```

**Need help?**
- Check logs: `/var/log/torrent-blocking/`
- Read: `DEPLOYMENT-CHECKLIST.md`
- Review: `IMPROVEMENTS.md`

---

## 📊 Installation Options

### Option 1: Enhanced (Recommended) ⭐
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/install-enhanced.sh && chmod +x install-enhanced.sh && sudo bash install-enhanced.sh
```
**Best for:** Production servers
**Features:** All features included

### Option 2: Basic (iptables)
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/btorrent.sh && chmod +x btorrent.sh && sudo bash btorrent.sh
```
**Best for:** Simple setups
**Features:** Domain blocking only

### Option 3: Basic (nftables)
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/block-torrent-nftables.sh && chmod +x block-torrent-nftables.sh && sudo bash block-torrent-nftables.sh
```
**Best for:** Modern systems
**Features:** Domain blocking only

---

## 🎓 Next Steps

### Step 1: Install (2 minutes)
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/install-enhanced.sh && chmod +x install-enhanced.sh && sudo bash install-enhanced.sh
```

### Step 2: Verify (1 minute)
```bash
cat /var/log/torrent-blocking/blocking-stats.txt
```

### Step 3: Monitor (Ongoing)
```bash
tail -f /var/log/torrent-blocking/blocked-domains.log
```

### Step 4: Learn More (Optional)
- Read `README.md` for complete documentation
- Read `IMPROVEMENTS.md` for advanced features
- Follow `DEPLOYMENT-CHECKLIST.md` for production setup

---

## 💡 Pro Tips

1. **Test first** - Run in non-production environment first
2. **Monitor logs** - Check logs weekly for new torrent sites
3. **Keep updated** - Blocklists update automatically weekly
4. **Backup config** - Automatic backups are created
5. **Easy uninstall** - Can be removed anytime with one command

---

## 🛡️ Security

✅ Automatic backups of all configurations
✅ Non-destructive installation
✅ Easy rollback/uninstall
✅ Comprehensive logging
✅ Regular blocklist updates
✅ Email alert system (optional)

---

## 📁 What's Included

- ✅ Enhanced installation script
- ✅ 4,472 blocked domains
- ✅ Port blocking
- ✅ Monitoring & logging
- ✅ Weekly auto-updates
- ✅ Automatic backups
- ✅ 8 documentation files
- ✅ 4 improvement scripts
- ✅ Configuration templates

---

## 🎉 Ready?

### Run This Now:
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/install-enhanced.sh && chmod +x install-enhanced.sh && sudo bash install-enhanced.sh
```

### Then Verify:
```bash
cat /var/log/torrent-blocking/blocking-stats.txt
```

---

## 📞 Need Help?

1. **Quick answers:** Read `QUICK-START.md`
2. **Step-by-step:** Follow `DEPLOYMENT-CHECKLIST.md`
3. **Advanced:** See `IMPROVEMENTS.md`
4. **All files:** Check `INDEX.md`

---

## 💚 You're All Set!

Your server is now protected from torrent and P2P traffic.

**Questions?** Check the documentation files or review the logs.

**Ready to install?** Copy the command above and run it!

---

**Last Updated:** 2025-11-23
**Status:** ✅ Ready to Use
