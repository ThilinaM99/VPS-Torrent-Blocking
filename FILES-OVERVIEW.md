# Project Files Overview

## 📁 Project Structure

```
block-torrent-on-server/
├── README.md                          # Main documentation
├── QUICK-START.md                     # Quick installation guide
├── IMPROVEMENTS.md                    # Advanced features
├── FILES-OVERVIEW.md                  # This file
│
├── Installation Scripts
├── ├── install-enhanced.sh            # ⭐ Recommended installer
├── ├── btorrent.sh                    # Basic iptables installer
├── └── block-torrent-nftables.sh      # Basic nftables installer
│
├── Uninstall Scripts
├── └── rollback-torrent-block.sh      # Rollback script
│
├── Blocklists
├── ├── domains                        # Domain blocklist (4,472 domains)
├── └── Thosts                         # Hosts file format (4,472 entries)
│
├── Improvement Scripts
├── ├── generate-subdomains.sh         # Expand domain list
├── ├── port-blocking.sh               # Block torrent ports
├── ├── auto-update-blocklist.sh       # Fetch from multiple sources
├── └── monitoring-logging.sh          # Setup logging & monitoring
│
└── Configuration Files
    └── dnsmasq-config.conf            # DNS-level blocking config
```

---

## 📄 File Descriptions

### Core Documentation

#### **README.md**
- Main project documentation
- Installation options (3 methods)
- Features comparison table
- Troubleshooting guide
- Security notes

#### **QUICK-START.md**
- 30-second installation guide
- Common commands
- Verification steps
- Troubleshooting tips

#### **IMPROVEMENTS.md**
- Advanced features documentation
- Detailed script descriptions
- Implementation strategy (3 phases)
- Performance comparison
- Security considerations

#### **FILES-OVERVIEW.md**
- This file
- Project structure
- File descriptions
- Usage guide

---

### Installation Scripts

#### **install-enhanced.sh** ⭐ RECOMMENDED
**Purpose:** Complete installation with all features
**Features:**
- Automatic firewall detection (iptables/nftables)
- Domain-level blocking
- Port-level blocking
- Hosts file blocking
- Monitoring & logging setup
- Weekly auto-updates
- Automatic backups
- Easy uninstall

**Installation:**
```bash
wget https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/install-enhanced.sh && chmod +x install-enhanced.sh && sudo bash install-enhanced.sh
```

**Creates:**
- `/opt/torrent-blocking/` - Installation directory
- `/etc/torrent-blocklists/` - Blocklists
- `/var/log/torrent-blocking/` - Logs
- `/var/backups/torrent-blocking/` - Backups

---

#### **btorrent.sh**
**Purpose:** Basic iptables-based installation
**Features:**
- Simple domain blocking
- Uses iptables firewall
- Daily rule updates
- Hosts file blocking

**Installation:**
```bash
wget https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/btorrent.sh && chmod +x btorrent.sh && sudo bash btorrent.sh
```

---

#### **block-torrent-nftables.sh**
**Purpose:** Basic nftables-based installation
**Features:**
- Simple domain blocking
- Uses modern nftables firewall
- Daily rule updates
- Hosts file blocking

**Installation:**
```bash
wget https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/block-torrent-nftables.sh && chmod +x block-torrent-nftables.sh && sudo bash block-torrent-nftables.sh
```

---

### Uninstall Scripts

#### **rollback-torrent-block.sh**
**Purpose:** Uninstall basic installation
**Features:**
- Removes firewall rules
- Restores original configuration
- Cleans up files

**Usage:**
```bash
wget https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/rollback-torrent-block.sh && chmod +x rollback-torrent-block.sh && sudo bash rollback-torrent-block.sh
```

---

### Blocklists

#### **domains**
**Purpose:** Plain text list of blocked domains
**Format:** One domain per line
**Size:** 4,472 domains
**Content:**
- Torrent trackers (1337x, RARBG, YTS, etc.)
- P2P networks
- Streaming sites
- File sharing services

**Usage:** Used by firewall rules and hosts file

---

#### **Thosts**
**Purpose:** Hosts file format blocklist
**Format:** `0.0.0.0 domain.com`
**Size:** 4,472 entries
**Content:** Same domains as `domains` file

**Usage:** Appended to `/etc/hosts` for DNS-level blocking

---

### Improvement Scripts

#### **generate-subdomains.sh**
**Purpose:** Expand domain list with variations
**Features:**
- Generates common subdomains (www, api, tracker, proxy, etc.)
- Adds TLD variations (.to, .xyz, .pw, .ru, .su, .me, .io, etc.)
- Removes duplicates
- Increases coverage 10-50x

**Usage:**
```bash
chmod +x generate-subdomains.sh
./generate-subdomains.sh
```

**Output:** `domains-expanded` file

---

#### **port-blocking.sh**
**Purpose:** Block BitTorrent ports at firewall level
**Features:**
- Blocks DHT ports (6881-6889)
- Blocks tracker port (6969)
- Blocks P2P application ports
- Works with iptables and nftables
- Blocks both incoming and outgoing

**Usage:**
```bash
chmod +x port-blocking.sh
sudo ./port-blocking.sh
```

**Ports Blocked:**
- 6881-6889 (DHT)
- 6969 (BitTorrent tracker)
- 51413 (Transmission)
- 4662, 4672 (eMule/eDonkey)

---

#### **auto-update-blocklist.sh**
**Purpose:** Fetch and merge blocklists from multiple sources
**Features:**
- Fetches from GitHub
- Integrates Pi-hole blocklists
- Adds Firebog community lists
- Merges and deduplicates
- Maintains backups
- Logs all updates

**Usage:**
```bash
chmod +x auto-update-blocklist.sh
sudo ./auto-update-blocklist.sh
```

**Setup as cron job:**
```bash
echo "0 2 * * * /path/to/auto-update-blocklist.sh" | sudo crontab -
```

---

#### **monitoring-logging.sh**
**Purpose:** Setup comprehensive logging and monitoring
**Features:**
- Creates logging infrastructure
- Tracks blocked attempts
- Generates daily statistics
- Sends email alerts
- Integrates with rsyslog

**Usage:**
```bash
chmod +x monitoring-logging.sh
sudo ./monitoring-logging.sh
```

**Log Files:**
- `/var/log/torrent-blocking/blocked-domains.log`
- `/var/log/torrent-blocking/blocking-stats.txt`
- `/var/log/torrent-blocking/torrent-blocks.log`

---

### Configuration Files

#### **dnsmasq-config.conf**
**Purpose:** DNS-level blocking configuration
**Features:**
- Blocks domains at DNS resolution
- Returns 0.0.0.0 for blocked domains
- Most efficient method
- Reduces bandwidth usage

**Installation:**
```bash
sudo cp dnsmasq-config.conf /etc/dnsmasq.d/torrent-blocking.conf
sudo systemctl restart dnsmasq
```

---

## 🎯 Quick Reference

### Installation Methods

| Method | Command | Best For |
|--------|---------|----------|
| **Enhanced** | `install-enhanced.sh` | Production, monitoring needed |
| **Basic (iptables)** | `btorrent.sh` | Simple setups, older systems |
| **Basic (nftables)** | `block-torrent-nftables.sh` | Modern systems |

### Uninstall Methods

| Method | Command |
|--------|---------|
| **Enhanced** | `sudo /opt/torrent-blocking/uninstall.sh` |
| **Basic** | `rollback-torrent-block.sh` |

### Common Tasks

| Task | Command |
|------|---------|
| View stats | `cat /var/log/torrent-blocking/blocking-stats.txt` |
| Update lists | `sudo /opt/torrent-blocking/update-blocklist.sh` |
| Check rules | `sudo iptables -L -n \| grep DROP` |
| Test blocking | `nslookup 1337x.com` |

---

## 📊 Feature Matrix

| Feature | Enhanced | Basic |
|---------|----------|-------|
| Domain blocking | ✅ | ✅ |
| Port blocking | ✅ | ❌ |
| Monitoring | ✅ | ❌ |
| Auto-updates | ✅ | ❌ |
| Logging | ✅ | ❌ |
| Backups | ✅ | ❌ |
| Easy uninstall | ✅ | ❌ |
| Firewall detection | ✅ | ❌ |

---

## 🚀 Recommended Setup

### Step 1: Install Enhanced
```bash
wget https://raw.githubusercontent.com/nikzad-avasam/block-torrent-on-server/main/install-enhanced.sh && chmod +x install-enhanced.sh && sudo bash install-enhanced.sh
```

### Step 2: Verify Installation
```bash
cat /var/log/torrent-blocking/blocking-stats.txt
```

### Step 3: Monitor Logs
```bash
tail -f /var/log/torrent-blocking/blocked-domains.log
```

### Step 4: Check Updates
```bash
cat /etc/torrent-blocklists/update.log
```

---

## 📝 File Sizes

| File | Size | Type |
|------|------|------|
| domains | ~75 KB | Blocklist |
| Thosts | ~111 KB | Hosts file |
| install-enhanced.sh | ~12 KB | Script |
| btorrent.sh | ~1 KB | Script |
| block-torrent-nftables.sh | ~2 KB | Script |
| README.md | ~6 KB | Documentation |
| IMPROVEMENTS.md | ~15 KB | Documentation |
| QUICK-START.md | ~4 KB | Documentation |

---

## 🔐 Security Considerations

✅ **What's Protected:**
- Torrent traffic blocked at firewall level
- P2P connections prevented
- Unauthorized downloads stopped
- Server protected from datacenter bans

⚠️ **Important:**
- Root access required for installation
- Test in non-production first
- Maintain configuration backups
- Monitor for false positives
- Keep blocklists updated

---

## 📞 Support Resources

- **GitHub:** https://github.com/nikzad-avasam/block-torrent-on-server
- **Documentation:** See README.md
- **Quick Help:** See QUICK-START.md
- **Advanced:** See IMPROVEMENTS.md

---

**Last Updated:** 2025-11-23
