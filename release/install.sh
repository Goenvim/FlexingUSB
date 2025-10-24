#!/bin/bash
# FlexingUSB Installation Script - v1.1.0

set -e

echo "Installing FlexingUSB v1.1.0..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "ERROR: This tool is only supported on macOS"
    exit 1
fi

# Check for sudo access
if ! sudo -v; then
    echo "ERROR: This script requires sudo access"
    exit 1
fi

# Install the binary
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="FlexingUSB"

echo "Copying FlexingUSB to $INSTALL_DIR..."
sudo cp "$BINARY_NAME" "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"

echo ""
echo "SUCCESS: FlexingUSB v1.1.0 has been installed!"
echo ""
echo "What's new in v1.1.0:"
echo "  - 3-5x faster writes with Direct I/O (30-50 MB/s!)"
echo "  - Real progress bar with live speed & ETA"
echo "  - Fake USB detection (Rufus-inspired)"
echo "  - Multiple hash algorithms (SHA-256, SHA-512)"
echo ""
echo "Usage:"
echo "  FlexingUSB start    # Create bootable USB"
echo "  FlexingUSB list     # List external drives"
echo "  FlexingUSB restore  # Restore USB drive"
echo "  FlexingUSB --help   # Show all commands"
echo ""
echo "Run 'FlexingUSB --help' to get started."
