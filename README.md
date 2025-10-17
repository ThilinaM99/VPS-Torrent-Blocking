# 🛡️ Advanced Torrent Blocker v3.0 for VPS
A **production-grade firewall automation script** that detects and blocks torrent traffic on Linux VPS servers.  
Built for **sysadmins, hosting providers, and panel operators** (Xray, 3x-ui, Nginx, etc.), it combines **performance**, **automation**, and **real-time monitoring** — all in one lightweight shell script.

---

## 🚀 Features

### ✅ Multi-layer Protection
- Blocks **torrent trackers**, **torrent websites**, and **P2P ports (6881–6900, 51413)**
- DNS blocking via `/etc/hosts`
- Deep Packet Inspection (DPI) for BitTorrent protocol signatures

### ✅ Performance Optimized
- Uses `ipset` + `conntrack` for lightning-fast lookups  
- Kernel tuning for high-traffic environments  
- Minimal CPU load (<2%) even on small VPS setups

### ✅ Automation
- Daily **auto-update** of tracker IPs (via cron)
- Persistent across reboots (`netfilter-persistent` + systemd)
- Built-in **backup** and one-command **uninstall**

### ✅ Monitoring & Logging
- Real-time system metrics (CPU, memory, conntrack usage)
- Logs all updates to `/var/log/torrent-blocker.log`
- `torrent-blocker status` shows live blocking stats

### ✅ Webhook Alerts
- Optional **Discord / Telegram / Slack** integration  
- Sends alerts when large updates occur (customizable threshold)

### ✅ Duplicate Protection
- Prevents redundant entries in `/etc/hosts`
- Clean and centralized configuration at `/opt/torrent-blocker/config.conf`

---

## 🧩 Supported Systems

| OS | Status |
|----|--------|
| Ubuntu 20.04 / 22.04 / 24.04 | ✅ Tested |
| Debian 10 / 11 / 12 | ✅ Tested |
| AlmaLinux / Rocky / CentOS Stream 8+ | ⚙️ Minor adjustments |
| Panels (Xray / 3x-ui / Nginx-based) | ✅ Compatible |

---

## ⚙️ Installation

Run as **root** or with **sudo privileges**:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/torrent_block.sh)
```

Once installed:

```bash
source ~/.bashrc
torrent-blocker status
```

---

## 🧠 Management Commands

| Command | Description |
|----------|--------------|
| `torrent-blocker status` | Show current blocking stats and system load |
| `torrent-blocker update` | Manually refresh tracker IPs |
| `torrent-blocker webhook` | Configure webhook alerts (Discord, Telegram, Slack) |
| `torrent-blocker uninstall` | Completely remove the firewall and restore system |

---

## 📊 Logs & Metrics

- **Log file:** `/var/log/torrent-blocker.log`  
- **Backup directory:** `/root/torrent-block-backup-*`  
- **Config file:** `/opt/torrent-blocker/config.conf`  
- **System load and connection stats** logged automatically

---

## ⚠️ Notes

- Encrypted torrent traffic (VPN or obfuscated) may bypass DPI detection.  
- IPv6 blocking is optional and can be added if required.  
- If **UFW** is active, the script will prompt to disable or merge rules to avoid conflicts.

---

## 📢 Example Webhook Output

**Discord / Telegram / Slack Alert Example:**
```
🛡️ Torrent Blocker Alert
Added 134 new tracker IPs.
Total blocked: 4,580 trackers, 1,102 sites.
```

---

## ❤️ Contribute

Pull requests, bug reports, and tracker updates are always welcome!  
If you find new torrent domains or trackers, submit them via a **PR or issue**.

---

## 📄 License
**MIT License** — free to use, modify, and distribute.

---

> Developed with ❤️ by [ThilinaM99](https://github.com/ThilinaM99)  
> A lightweight, secure, and automated solution to protect your VPS from torrent abuse.
