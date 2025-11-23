# 🔧 nftables Bug Fix

## Issue Fixed

**Error:** `syntax error, unexpected string, expecting end of file or newline or semicolon`

**Cause:** The `nft list chains` command output format was being parsed incorrectly.

---

## What Was Changed

### Before (Broken)
```bash
nft list chains inet torrentblock | grep -q '^chain domainblock$' || \
    nft add chain inet torrentblock domainblock { type filter hook output priority 0 \; }
```

### After (Fixed)
```bash
nft list chains inet torrentblock 2>/dev/null | grep -q 'domainblock' || \
    nft add chain inet torrentblock domainblock { type filter hook output priority 0 \; }
```

**Changes:**
1. Added `2>/dev/null` to suppress errors if chain doesn't exist
2. Changed grep pattern from `'^chain domainblock$'` to `'domainblock'` (more flexible)
3. Updated GitHub URLs from old repo to new repo

---

## How to Fix Your Installation

### Option 1: Re-run Installation (Recommended)
```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh)"
```

### Option 2: Manual Fix
If you already have a partial installation, run:

```bash
# Clean up old nftables rules
sudo nft delete table inet torrentblock 2>/dev/null || true

# Then run the installer again
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/INSTALL.sh)"
```

### Option 3: Use Basic Installation
If you prefer a simpler setup:

```bash
# For iptables
wget https://raw.githubusercontent.com/ThilinaM99/VPS-Torrent-Blocking/main/btorrent.sh && chmod +x btorrent.sh && sudo bash btorrent.sh
```

---

## Verification After Fix

After running the fixed installer, verify it works:

```bash
# Check if nftables rules are created
sudo nft list ruleset | grep torrentblock

# Check if domains are blocked
nslookup 1337x.com
# Should return 0.0.0.0 or timeout

# View blocking statistics
cat /var/log/torrent-blocking/blocking-stats.txt
```

---

## What's Fixed

✅ nftables syntax error resolved
✅ GitHub URLs updated to new repository
✅ Better error handling in chain detection
✅ More flexible pattern matching

---

## Files Updated

- `install-enhanced.sh` - Fixed nftables configuration and GitHub URLs

---

## Status

✅ **Bug Fixed and Ready to Use**

The installation should now complete successfully on systems with nftables!

---

**Last Updated:** 2025-11-23
