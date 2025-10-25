#!/bin/bash
# FlexingUSB Installation Script
# This script installs FlexingUSB from the GitHub repository

set -e  # Exit on any error

echo "Installing FlexingUSB v1.1.5..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "FlexingUSB is designed for macOS only."
    exit 1
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    print_error "Git is required but not installed."
    echo "Please install Git first: https://git-scm.com/downloads"
    exit 1
fi

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    print_error "Swift is required but not installed."
    echo "Please install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi

# Check if make is available
if ! command -v make &> /dev/null; then
    print_error "Make is required but not installed."
    echo "Please install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
print_status "Using temporary directory: $TEMP_DIR"

# Clone repository
print_status "Cloning FlexingUSB repository..."
if ! git clone https://github.com/Goenvim/FlexingUSB.git "$TEMP_DIR/FlexingUSB"; then
    print_error "Failed to clone repository. Please check your internet connection."
    exit 1
fi

cd "$TEMP_DIR/FlexingUSB"

# Build and install
print_status "Building FlexingUSB..."
if ! make install; then
    print_error "Failed to build or install FlexingUSB."
    exit 1
fi

# Clean up
print_status "Cleaning up temporary files..."
cd /
rm -rf "$TEMP_DIR"

# Verify installation
print_status "Verifying installation..."
if command -v FlexingUSB &> /dev/null && command -v flexingusb &> /dev/null; then
    print_success "FlexingUSB installed successfully!"
    echo ""
    echo "You can now use FlexingUSB from anywhere:"
    echo "  FlexingUSB --help"
    echo "  flexingusb --help"
    echo ""
    echo "Quick start:"
    echo "  flexingusb start"
    echo "  flexingusb list"
    echo "  flexingusb quick flash --iso /path/to/file.iso"
    echo ""
    print_success "Installation complete!"
else
    print_error "Installation verification failed."
    exit 1
fi
