# FlexingUSB v1.0.0 - Release Notes

## What to Upload to GitHub Release

Upload these files as release assets:

1. **FlexingUSB-v1.0.0-macos-with-installer.zip** (469 KB)
   - Contains: Binary + installation script
   - Recommended for most users

2. **FlexingUSB-v1.0.0-macos.zip** (468 KB)  
   - Contains: Binary only
   - For advanced users who prefer manual installation

---

## Release Description

Copy this into your GitHub release description:

```markdown
# FlexingUSB v1.0.0

A macOS command-line utility for safely writing ISO images to USB drives.

## Installation

### Quick Install (Recommended)

Download and run the installer:

```bash
# Download the release
curl -L https://github.com/Goenvim/FlexingUSB/releases/download/v1.0.0/FlexingUSB-v1.0.0-macos-with-installer.zip -o FlexingUSB.zip

# Extract
unzip FlexingUSB.zip

# Install
cd FlexingUSB-v1.0.0-macos-with-installer
sudo ./install.sh
```

### Manual Install

```bash
# Download binary only
curl -L https://github.com/Goenvim/FlexingUSB/releases/download/v1.0.0/FlexingUSB-v1.0.0-macos.zip -o FlexingUSB.zip

# Extract and install
unzip FlexingUSB.zip
sudo mv FlexingUSB /usr/local/bin/
sudo chmod +x /usr/local/bin/FlexingUSB
```

### Build from Source

```bash
git clone https://github.com/Goenvim/FlexingUSB.git
cd FlexingUSB
make install
```

## Features

- **Safe Operations**: Multiple validation layers prevent accidental data loss
- **Automatic Detection**: Detects ISO type (Windows, Linux, macOS)
- **Verification**: SHA256 checksum verification ensures integrity
- **Interactive UI**: Colorized terminal output with progress indicators
- **Native Integration**: macOS file picker for ISO selection
- **USB Restoration**: Format USB drives back to FAT32/exFAT

## Usage

```bash
# Create bootable USB (interactive)
FlexingUSB start

# List all external drives
FlexingUSB list

# Restore USB to normal format
FlexingUSB restore

# Verify written ISO
FlexingUSB verify <iso-path> <disk-identifier>

# Test without writing
FlexingUSB start --dry-run
```

## System Requirements

- macOS 10.15 (Catalina) or later
- Administrator privileges for disk operations
- External USB drive

## What's New in v1.0.0

Initial release with core functionality:
- ISO-to-USB writing workflow
- External disk detection and safety checks
- SHA256 verification
- USB restoration
- Interactive terminal interface
- Dry-run mode for testing

## Known Limitations

- Windows ISO TPM patching is informational only (actual patching not implemented)
- Progress indicator for `dd` writes is a spinner (not percentage-based)
- Requires sudo access for disk operations

## Documentation

- [README](https://github.com/Goenvim/FlexingUSB#readme) - Full documentation
- [Quick Start Guide](https://github.com/Goenvim/FlexingUSB/blob/main/QUICKSTART.md)
- [Examples](https://github.com/Goenvim/FlexingUSB/blob/main/EXAMPLES.md)
- [Contributing](https://github.com/Goenvim/FlexingUSB/blob/main/CONTRIBUTING.md)

## Support

- Report bugs: [GitHub Issues](https://github.com/Goenvim/FlexingUSB/issues)
- Discussions: [GitHub Discussions](https://github.com/Goenvim/FlexingUSB/discussions)

---

**Full Changelog**: Initial release
```

---

## Creating the Release on GitHub

1. Go to: https://github.com/Goenvim/FlexingUSB/releases/new

2. Fill in:
   - **Tag**: `v1.0.0`
   - **Target**: `main`
   - **Title**: `FlexingUSB v1.0.0`
   - **Description**: Copy the text above

3. **Attach files**:
   - Drag and drop both `.zip` files into the "Attach binaries" area

4. Check "Set as the latest release"

5. Click **"Publish release"**

---

## Post-Release

After publishing:

1. **Add topics** to repository:
   - swift, macos, cli, usb, iso, bootable-usb

2. **Pin the release**:
   - Go to Releases tab
   - Click the pin icon next to v1.0.0

3. **Update README badges** (optional):
   - Add release badge
   - Add build status badge
