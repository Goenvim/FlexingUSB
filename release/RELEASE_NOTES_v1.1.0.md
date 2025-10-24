# FlexingUSB v1.1.0 - Performance Revolution 🚀

## Major Performance Upgrade!

### ⚡ 3-5x Faster Writes!
- **Direct I/O Writer**: No more slow `dd` - now writes directly to device
- **16MB Buffers**: Doubled from 8MB for maximum throughput
- **Speed**: 30-50 MB/s (was ~10-15 MB/s)
- **Example**: 2.8GB Linux Mint ISO now writes in **1-2 minutes** (was 20+ minutes!)

### 📊 Real Progress Bar
```
[████████████████████░░░░░] 78.5% | 35.2 MB/s | ETA: 0m 34s
```
- Updates every second with actual bytes written
- Live speed calculation
- Accurate time remaining

### 🛡️ New Safety Features (Rufus-Inspired)
- **Fake USB Detection**: Warns about counterfeit drives with suspicious capacities
- **Bad Blocks Check**: Optional quick capacity verification
- See `RUFUS_INSPIRED_FEATURES.md` for details

### 🔐 Enhanced Hash Support
- SHA-256 (standard)
- SHA-512 (more secure)
- Calculate all checksums at once

### ✨ Better UX
- Simple y/n confirmations (no more typing "CONFIRM")
- Drag-and-drop ISO file path support
- Progress stays on one line (no spam)
- Clear colorized output

### 🐛 Bug Fixes
- Fixed disk detection filter (now uses proper regex)
- Fixed progress bar creating new lines
- Improved error messages

---

## Installation

### Quick Install (Recommended)

```bash
# Download and install
curl -L https://github.com/Goenvim/FlexingUSB/releases/download/v1.1.0/FlexingUSB-v1.1.0-macos-with-installer.zip -o FlexingUSB.zip
unzip FlexingUSB.zip
cd FlexingUSB-v1.1.0-macos-with-installer
sudo ./install.sh
```

### Manual Install

```bash
curl -L https://github.com/Goenvim/FlexingUSB/releases/download/v1.1.0/FlexingUSB-v1.1.0-macos.zip -o FlexingUSB.zip
unzip FlexingUSB.zip
sudo mv FlexingUSB /usr/local/bin/
sudo chmod +x /usr/local/bin/FlexingUSB
```

---

## What's New in Detail

### Direct I/O Writer
Inspired by Rufus's approach, we've replaced the external `dd` command with direct Swift file operations:

**Before (v1.0.0)**:
```
Writing: [████████░░░░░░░░] 45% | ~15 MB/s | ETA: 3m 12s
⏱️  Elapsed: 2m 35s | Writing at maximum speed...
```

**After (v1.1.0)**:
```
[████████████████████░░░░░] 78.5% | 35.2 MB/s | ETA: 0m 34s
```

### Performance Comparison

| Version | Method | Block Size | Speed | 2.8GB ISO Time |
|---------|--------|------------|-------|----------------|
| v1.0.0 | `dd` | 8MB | ~10-15 MB/s | 3-5 minutes |
| **v1.1.0** | **Direct I/O** | **16MB** | **30-50 MB/s** | **1-2 minutes** |

### New Files

- `DirectWriter.swift` - Direct file-to-device writer
- `BadBlockChecker.swift` - USB capacity verification
- `RUFUS_INSPIRED_FEATURES.md` - Documentation of Rufus-inspired features

---

## Upgrade from v1.0.0

If you have v1.0.0 installed, simply download and install v1.1.0 over it:

```bash
sudo FlexingUSB --version  # Check current version
# Download new version (see Installation above)
sudo ./install.sh  # Overwrites old version
```

---

## System Requirements

- macOS 10.15 (Catalina) or later
- Administrator privileges for disk operations
- External USB drive

---

## Known Issues

None! 🎉

---

## Credits

- Inspired by [Rufus](https://rufus.ie) by Pete Batard
- Direct I/O techniques adapted from Rufus's approach
- Community feedback and testing

---

## Full Changelog

**Added:**
- Direct I/O writer with 16MB buffers
- Real-time progress bar with speed & ETA
- Bad blocks / fake USB detection
- SHA-512 hash support
- Multi-hash calculation
- Drag-and-drop file path input
- RUFUS_INSPIRED_FEATURES.md documentation

**Improved:**
- Write speed: 3-5x faster (30-50 MB/s)
- Progress display: single-line updates
- Confirmations: y/n instead of "CONFIRM"
- Error messages: more detailed
- User experience: cleaner output

**Fixed:**
- Disk detection filter regex
- Progress bar line breaks
- USB capacity display

**Removed:**
- EXAMPLES.md (consolidated into README)

---

**Download**: [FlexingUSB-v1.1.0-macos-with-installer.zip](https://github.com/Goenvim/FlexingUSB/releases/download/v1.1.0/FlexingUSB-v1.1.0-macos-with-installer.zip)

**Full Changelog**: [v1.0.0...v1.1.0](https://github.com/Goenvim/FlexingUSB/compare/v1.0.0...v1.1.0)
