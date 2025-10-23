# Installation Guide

This guide will help you install FlexingUSB on your macOS system.

## Prerequisites

- macOS 10.15 (Catalina) or later
- Xcode Command Line Tools or Xcode 15.0+
- Administrator privileges for disk operations

### Install Xcode Command Line Tools

If you haven't already:

```bash
xcode-select --install
```

## Installation Methods

### Method 1: Build from Source (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/FlexingUSB.git
cd FlexingUSB

# Build and install
make install
```

This will:
1. Build a release version
2. Copy the binary to `/usr/local/bin/FlexingUSB`
3. Make it available system-wide

### Method 2: Manual Build and Copy

```bash
# Clone and navigate
git clone https://github.com/yourusername/FlexingUSB.git
cd FlexingUSB

# Build release version
swift build -c release

# Manually copy to PATH
sudo cp .build/release/FlexingUSB /usr/local/bin/
```

### Method 3: Homebrew (Coming Soon)

```bash
# Future installation method
brew install flexingusb
```

## Verify Installation

After installation, verify it works:

```bash
# Check version and help
FlexingUSB --help

# List available commands
FlexingUSB list
```

## Usage

### Quick Start

1. **Connect a USB drive** to your Mac

2. **Run FlexingUSB**:
   ```bash
   FlexingUSB start
   ```

3. **Follow the interactive prompts**:
   - Select your USB drive from the list
   - Choose an ISO file using the Finder dialog
   - Confirm the operation
   - Wait for the write to complete

### Common Commands

```bash
# List all external USB drives
FlexingUSB list

# Start interactive ISO writing
FlexingUSB start

# Restore a USB drive to normal format
FlexingUSB restore

# Verify a written USB
FlexingUSB verify /path/to/image.iso disk2

# Dry run (simulate without writing)
FlexingUSB start --dry-run
```

## Updating

To update to the latest version:

```bash
cd FlexingUSB
git pull
make install
```

## Uninstalling

To remove FlexingUSB:

```bash
# Using Makefile
make uninstall

# Or manually
sudo rm /usr/local/bin/FlexingUSB
```

## Troubleshooting

### "Command not found"

If you get "command not found" after installation:

1. Check if `/usr/local/bin` is in your PATH:
   ```bash
   echo $PATH
   ```

2. If not, add it to your shell profile (`~/.zshrc` or `~/.bash_profile`):
   ```bash
   export PATH="/usr/local/bin:$PATH"
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

### "Permission denied"

If you get permission errors:

1. FlexingUSB requires sudo for disk operations
2. You'll be prompted for your password when needed
3. Ensure you're an administrator on your Mac

### Build Errors

If you encounter build errors:

1. Ensure you have Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

2. Update Swift to the latest version:
   ```bash
   swift --version  # Should be 5.9+
   ```

3. Clean and rebuild:
   ```bash
   make clean
   make build
   ```

## Development Setup

For contributors and developers:

```bash
# Clone the repo
git clone https://github.com/yourusername/FlexingUSB.git
cd FlexingUSB

# Build debug version
swift build

# Run without installing
swift run FlexingUSB list

# Run with arguments
swift run FlexingUSB start --dry-run

# Open in Xcode
open Package.swift
```

## System Requirements

- **OS**: macOS 10.15 or later
- **RAM**: 100MB minimum
- **Disk Space**: 20MB for installation
- **USB Drive**: Any external USB drive (will be erased)
- **Privileges**: Administrator access required

## Getting Help

- **Documentation**: See [README.md](README.md)
- **Issues**: Report bugs on GitHub
- **Discussions**: Ask questions in GitHub Discussions
- **Help Command**: Run `FlexingUSB --help` for built-in help

---

## Next Steps

After installation:

1. Read the [README.md](README.md) for detailed usage
2. Check out [CONTRIBUTING.md](CONTRIBUTING.md) if you want to contribute
3. Review safety features to understand the tool's protections
4. Try a dry run first: `FlexingUSB start --dry-run`

Happy ISO writing! 
