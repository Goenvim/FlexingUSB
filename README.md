# FlexingUSB

<p align="center">
  <strong>A powerful, safe, and intelligent macOS command-line tool for writing ISO images to USB drives</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.9+-orange.svg" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License">
</p>

---

## Overview

**FlexingUSB** is a native Swift command-line utility designed to make ISO-to-USB creation simple, safe, and transparent for macOS users. It's a modern alternative to tools like `dd`, `asr`, and Etcher—but entirely terminal-based with professional-grade safety features.

**macOS versions:** Supported on Catalina (10.15) and newer.

**Requirements:** Admin/sudo, external USB drive, and that you’re OK with the tool unmounting/erasing the target disk.

**Performance:** Similar or better on Intel—actual speed depends on your USB port (USB 2.0 vs 3.x), the drive, and the ISO size.

### Key Features

- **Safety First**: Never touches internal drives (`/dev/disk0`) - multiple safety checks prevent accidents
- **Intelligent Detection**: Automatically detects ISO types (Windows, Linux, macOS)
- **Verification**: SHA256 checksum verification ensures data integrity
- **User-Friendly**: Colorized terminal output with progress indicators
- **Transparency**: Shows exactly what will happen before any destructive operation
- **Finder Integration**: Native macOS file picker for ISO selection
- **USB Restoration**: Easy restoration of USB drives to FAT32/exFAT

---

## Installation

### Option 1: Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/FlexingUSB.git
cd FlexingUSB

# Build with Swift Package Manager
swift build -c release

# Copy to PATH (optional)
sudo cp .build/release/FlexingUSB /usr/local/bin/
```

### Option 2: Xcode

```bash
# Open the package in Xcode
open Package.swift

# Build and run from Xcode (⌘+R)
```

### Option 3: Homebrew (Future)

```bash
# Coming soon!
brew install flexingusb
```

---

## Usage

### Quick Start

```bash
# Interactive ISO-to-USB workflow
FlexingUSB start

# List all external drives
FlexingUSB list

# Restore a USB to FAT32/exFAT
FlexingUSB restore

# Verify a written ISO
FlexingUSB verify /path/to/image.iso disk2
```

### Commands

#### `start` - Flash an ISO to USB

The main command that guides you through the entire process:

```bash
FlexingUSB start [--dry-run] [--skip-verify]
```

**Workflow:**
1. Detects all external USB drives
2. Opens Finder to select an ISO file
3. Detects ISO type (Windows/Linux/macOS)
4. Optionally provides Windows TPM bypass information
5. Requires explicit "CONFIRM" before writing
6. Writes ISO to USB with progress indication
7. Optionally verifies written data

**Options:**
- `--dry-run`: Simulate the operation without actually writing
- `--skip-verify`: Skip the verification step after writing

#### `list` - Show External Drives

Lists all connected external USB drives with detailed information:

```bash
FlexingUSB list
```

**Output:**
```
═══ External Drives ═══

Detected external drives:
[1] /dev/disk2 - 64.00GB SanDisk Ultra (GUID_partition_scheme)

Device: /dev/disk2
  Size: 64.00 GB
  Content: GUID_partition_scheme
  Volume: SanDisk
  Mounted: /Volumes/SanDisk
```

#### `restore` - Restore USB Drive

Erases and formats a USB drive back to a usable state:

```bash
FlexingUSB restore [--format FAT32|ExFAT] [--name VolumeName]
```

**Options:**
- `--format`: Specify format (FAT32 or ExFAT). Auto-detects based on size if not specified
- `--name`: Custom volume name (default: "Untitled")

**Example:**
```bash
FlexingUSB restore --format ExFAT --name "MyUSB"
```

#### `verify` - Verify Written ISO

Verifies that a USB drive matches an ISO file:

```bash
FlexingUSB verify <iso-path> <disk-identifier>
```

**Arguments:**
- `iso-path`: Path to the ISO file
- `disk-identifier`: Disk identifier (e.g., disk2)

**Example:**
```bash
FlexingUSB verify ~/Downloads/ubuntu.iso disk2
```

---

## Safety Features

FlexingUSB includes multiple layers of protection:

1. **Internal Disk Protection**: 
   - Automatically blocks operations on `/dev/disk0` (internal macOS disk)
   - Verifies disk is external before any operation

2. **Explicit Confirmation**:
   - Requires typing "CONFIRM" before destructive operations
   - Shows detailed information about what will be erased

3. **Dry Run Mode**:
   - Test operations without actually writing data
   - See exactly what commands would be executed

4. **Verification**:
   - Optional SHA256 checksum verification
   - Ensures written data matches source ISO

5. **Error Handling**:
   - Graceful error messages
   - Safe cleanup on failures

---

## Architecture

FlexingUSB is built with a modular, maintainable architecture:

```
FlexingUSB/
├── Package.swift              # Swift Package Manager configuration
├── Sources/FlexingUSB/
│   ├── main.swift            # CLI entry point & command routing
│   ├── DiskManager.swift     # Disk detection & operations
│   ├── ISOManager.swift      # ISO detection & validation
│   ├── Writer.swift          # ISO writing & verification
│   └── UI.swift              # Terminal UI & user interaction
└── README.md
```

### Module Responsibilities

- **`main.swift`**: ArgumentParser commands and workflow orchestration
- **`DiskManager.swift`**: Disk enumeration, safety checks, formatting
- **`ISOManager.swift`**: ISO type detection, file validation, checksum calculation
- **`Writer.swift`**: ISO writing (dd/asr), progress monitoring, verification
- **`UI.swift`**: Terminal output, colors, progress bars, file pickers

---

## Technical Details

### Requirements

- **macOS**: 10.15 (Catalina) or later
- **Swift**: 5.9+
- **Xcode**: 15.0+ (for development)
- **Privileges**: sudo access for disk operations

### Technologies Used

- **Swift Package Manager**: Dependency management and building
- **ArgumentParser**: Command-line argument parsing
- **AppKit**: Native macOS file picker (NSOpenPanel)
- **CryptoKit**: SHA256 checksum calculation
- **Foundation**: File I/O and process execution

### Write Methods

FlexingUSB supports two write methods:

1. **dd** (default): Universal, reliable, works with all ISO types
   ```bash
   sudo dd if=image.iso of=/dev/rdisk2 bs=1m
   ```

2. **asr** (Apple Software Restore): Optimized for macOS, with fallback to dd
   ```bash
   sudo asr restore --source image.iso --target /dev/disk2 --erase
   ```

---

## Use Cases

### Creating Linux Bootable USB

```bash
# Download Ubuntu ISO
# Run FlexingUSB
FlexingUSB start

# Follow interactive prompts
# Boot from USB on target machine
```

### Creating Windows Installation USB

```bash
# Download Windows 11 ISO
FlexingUSB start

# Tool detects Windows and offers TPM bypass info
# Creates bootable Windows USB
```

### Creating macOS Installer USB

```bash
# Download macOS installer DMG/ISO
FlexingUSB start

# Creates bootable macOS installer
```

### Restoring USB After Use

```bash
# Restore USB to normal storage
FlexingUSB restore

# USB is now formatted and ready for files
```

---

## Troubleshooting

### "No external disks found"

**Problem**: FlexingUSB doesn't see your USB drive.

**Solutions**:
- Ensure USB drive is properly connected
- Try a different USB port
- Check Disk Utility to see if macOS recognizes the drive
- Try unplugging and replugging the drive

### "Permission denied" errors

**Problem**: Insufficient privileges for disk operations.

**Solutions**:
- FlexingUSB will automatically use `sudo` and prompt for password
- Ensure your user account has admin privileges
- Try running with explicit sudo: `sudo FlexingUSB start`

### Write is very slow

**Problem**: Writing takes longer than expected.

**Solutions**:
- This is normal for large ISOs (5-15 minutes for 4GB)
- Ensure you're using USB 3.0 ports for faster speeds
- dd method uses raw disk device (`/dev/rdisk`) for best performance
- Avoid USB hubs when possible

### Verification failed

**Problem**: USB checksum doesn't match ISO.

**Solutions**:
- The write may have failed - try writing again
- Check USB drive for hardware issues
- Try a different USB drive
- Verify ISO file isn't corrupted (check download)

### "Internal disk not allowed" error

**Problem**: Trying to use /dev/disk0.

**Solution**: This is intentional! FlexingUSB blocks operations on internal disks for safety. Use an external USB drive only.

---

## Contributing

Contributions are welcome! Here's how you can help:

### Development Setup

```bash
# Clone and setup
git clone https://github.com/yourusername/FlexingUSB.git
cd FlexingUSB

# Build and test
swift build
swift test  # when tests are added

# Format code (if using swift-format)
swift-format -i -r Sources/
```

### Areas for Contribution

- Add unit tests for disk parsing and safety checks
- Improve UI/UX with better progress indicators
- Implement actual Windows ISO patching (TPM removal)
- Add progress monitoring for dd writes (using SIGINFO)
- Create Homebrew formula for easy installation
- Add localization support
- Add write speed benchmarking
- Add SwiftUI front-end option

### Code Style

- Use Swift naming conventions
- Add doc comments for public APIs
- Keep functions focused and modular
- Include error handling for all operations
- Write descriptive commit messages

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 FlexingUSB Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Acknowledgments

- Inspired by tools like [Etcher](https://www.balena.io/etcher/), [Rufus](https://rufus.ie/), and traditional Unix utilities
- Built with Swift and modern macOS frameworks
- Thanks to the open-source community for feedback and contributions

---

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/FlexingUSB/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/FlexingUSB/discussions)
- **Email**: your.email@example.com

---

## Roadmap

### v1.0 (Current)
- Core ISO writing functionality
- Disk detection and safety checks
- USB restoration
- Verification support
- Interactive UI with colors

### v1.1 (Planned)
- Unit test suite
- Homebrew formula
- Better progress reporting for dd
- Write speed benchmarking

### v2.0 (Future)
- Full Windows ISO patching implementation
- GUI mode with SwiftUI
- Preset profiles for popular ISOs
- Multi-USB writing (parallel writes)
- Disk cloning functionality

---

<p align="center">
  Built for the macOS community
</p>
