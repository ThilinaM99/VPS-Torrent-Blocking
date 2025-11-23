# Block Torrent Traffic on Server + P2P Traffic
![images](https://github.com/user-attachments/assets/5f953f29-de91-460f-85de-855b453fce88)

By using this script, you can block all torrent and P2P traffic on your server or VPS. This will prevent your server from being blocked by the datacenter. **Using torrent is illegal in many jurisdictions.**

---

## 🚀 Quick Installation

### **⚡ Fastest Way (One Command)**
Copy and paste this single command:

```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh)"
```

**That's it!** Installation will complete in 2-3 minutes.

---

### **Option 1: Enhanced Installation (Recommended)**
Complete installation with all improvements, monitoring, and auto-updates:

```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/install-enhanced.sh && chmod +x install-enhanced.sh && sudo bash install-enhanced.sh
```

**Features:**
- ✅ Automatic firewall detection (iptables/nftables)
- ✅ Domain-level blocking
- ✅ Port-level blocking (BitTorrent ports)
- ✅ Hosts file blocking
- ✅ Monitoring & logging
- ✅ Weekly auto-updates
- ✅ Automatic backups
- ✅ Easy uninstall

---

### **Option 2: Basic Installation (iptables)**
Simple installation using iptables:

```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/btorrent.sh && chmod +x btorrent.sh && sudo bash btorrent.sh
```

---

### **Option 3: Basic Installation (nftables)**
Simple installation using nftables (modern firewall):

```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/block-torrent-nftables.sh && chmod +x block-torrent-nftables.sh && sudo bash block-torrent-nftables.sh
```

---

## 🔧 Uninstall

### **Enhanced Installation:**
```bash
sudo /opt/torrent-blocking/uninstall.sh
```

### **Basic Installation:**
```bash
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/rollback-torrent-block.sh && chmod +x rollback-torrent-block.sh && sudo bash rollback-torrent-block.sh
```

---

## 📊 Features Comparison

| Feature | Basic | Enhanced |
|---------|-------|----------|
| Domain blocking | ✅ | ✅ |
| Port blocking | ❌ | ✅ |
| Monitoring | ❌ | ✅ |
| Auto-updates | ❌ | ✅ |
| Logging | ❌ | ✅ |
| Automatic backups | ❌ | ✅ |
| Easy uninstall | ❌ | ✅ |
| Firewall detection | ❌ | ✅ |

---

## 📋 What Gets Blocked

- **Torrent trackers** (1337x, The Pirate Bay, RARBG, etc.)
- **P2P networks** (BitTorrent, DHT, etc.)
- **Torrent ports** (6881-6889, 6969, 51413, etc.)
- **Streaming sites** (movie/TV streaming)
- **File sharing sites** (MEGA, Mediafire, etc.)

---

## 🔍 Monitoring & Logs

After enhanced installation, view statistics:

```bash
cat /var/log/torrent-blocking/blocking-stats.txt
```

View blocked attempts:

```bash
tail -f /var/log/torrent-blocking/blocked-domains.log
```

Check update logs:

```bash
cat /etc/torrent-blocklists/update.log
```

---

## 🛡️ Security Notes

⚠️ **Important:**
- Root/sudo access required
- Test in non-production environment first
- Maintain backups (automatically done)
- Monitor for false positives
- Keep blocklists updated regularly

---

## 📁 Installation Directories

Enhanced installation creates:
- `/opt/torrent-blocking/` - Installation directory
- `/etc/torrent-blocklists/` - Blocklists
- `/var/log/torrent-blocking/` - Logs
- `/var/backups/torrent-blocking/` - Backups

---

## 🔄 Manual Updates

Update blocklists manually:

```bash
sudo /opt/torrent-blocking/update-blocklist.sh
```

---

## 🐛 Troubleshooting

**Rules not applying?**
```bash
# Check iptables
sudo iptables -L -n | grep DROP

# Check nftables
sudo nft list ruleset
```

**Check if blocking is working:**
```bash
# Try to resolve a blocked domain
nslookup 1337x.com
# Should return 0.0.0.0 or timeout
```

---

## 📚 Additional Scripts

The repository includes additional improvement scripts:

- `generate-subdomains.sh` - Expand domain list with subdomains
- `port-blocking.sh` - Standalone port blocking
- `auto-update-blocklist.sh` - Fetch from multiple sources
- `monitoring-logging.sh` - Advanced logging setup
- `dnsmasq-config.conf` - DNS-level blocking config

See `IMPROVEMENTS.md` for details.

---

## 💚 Stay Safe

This project helps protect your server from legal issues related to torrent usage.

**Enhanced By:** ThilinaM99  
**GitHub:** https://github.com/ThilinaM99/VPS-Torrent-Blocking  
**Original Author:** [avasam](https://avasam.ir)  
**Original GitHub:** https://github.com/nikzad-avasam/block-torrent-on-server

---

**Last Updated:** 2025-11-23
