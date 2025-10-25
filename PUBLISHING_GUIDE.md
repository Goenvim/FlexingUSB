# Publishing FlexingUSB to GitHub - Complete Guide

## Prerequisites
- Git installed on your system
- GitHub account
- Your FlexingUSB project ready for publishing

## Step 1: Initialize Git Repository (if not already done)

```bash
cd /Users/romangrzadziel/Documents/FlexingUSB

# Check if git is already initialized
git status

# If not initialized, run:
git init
```

## Step 2: Create .gitignore File

Create a `.gitignore` file to exclude build artifacts and temporary files:

```bash
cat > .gitignore << 'EOF'
# Build artifacts
.build/
*.xcodeproj/
*.xcworkspace/

# Swift Package Manager
.swiftpm/
Package.resolved

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Temporary files
*.tmp
*.temp
*.log

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Release artifacts
release/
*.zip
*.dmg
EOF
```

## Step 3: Add All Files to Git

```bash
# Add all files to git
git add .

# Check what will be committed
git status
```

## Step 4: Create Initial Commit

```bash
# Create initial commit
git commit -m "Initial commit: FlexingUSB v1.1.0 with enhanced features

- Added global launcher script (flexingusb command)
- Enhanced ISO technical specifications
- Enhanced USB drive technical specifications  
- Added quick operations for common tasks
- Improved system integration and documentation
- Added specs and quick commands
- Updated Makefile and README with new features"
```

## Step 5: Create GitHub Repository

### Option A: Using GitHub CLI (if installed)
```bash
# Create repository on GitHub
gh repo create FlexingUSB --public --description "A powerful, safe, and intelligent macOS command-line tool for writing ISO images to USB drives"

# Add remote origin
git remote add origin https://github.com/YOUR_USERNAME/FlexingUSB.git

# Push to GitHub
git push -u origin main
```

### Option B: Using GitHub Web Interface
1. Go to [GitHub.com](https://github.com)
2. Click "New repository" (green button)
3. Repository name: `FlexingUSB`
4. Description: `A powerful, safe, and intelligent macOS command-line tool for writing ISO images to USB drives`
5. Make it **Public**
6. **Don't** initialize with README, .gitignore, or license (we already have these)
7. Click "Create repository"

## Step 6: Connect Local Repository to GitHub

```bash
# Add remote origin (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/FlexingUSB.git

# Verify remote was added
git remote -v
```

## Step 7: Push to GitHub

```bash
# Push to GitHub
git push -u origin main
```

## Step 8: Create a Release (Optional but Recommended)

### Using GitHub Web Interface:
1. Go to your repository on GitHub
2. Click "Releases" → "Create a new release"
3. Tag version: `v1.1.0`
4. Release title: `FlexingUSB v1.1.0 - Enhanced Features`
5. Description:
```markdown
## What's New in v1.1.0 🚀

**Enhanced Features & Better UX!**

### New Features
- ⚡ **Global Launcher**: Use `flexingusb` command from anywhere
- 📊 **Technical Specifications**: Detailed ISO and USB drive analysis
- 🚀 **Quick Operations**: Fast shortcuts for common tasks
- 🔧 **Better Integration**: Improved system integration

### New Commands
- `FlexingUSB specs --iso <path>` - Analyze ISO files
- `FlexingUSB specs --usb <disk>` - Analyze USB drives  
- `FlexingUSB quick flash --iso <path>` - Quick flash
- `FlexingUSB quick restore` - Quick restore
- `flexingusb` - Shorter command (launcher script)

### Installation
```bash
# Clone and install
git clone https://github.com/YOUR_USERNAME/FlexingUSB.git
cd FlexingUSB
make install
```

### Usage
```bash
# Use from anywhere
flexingusb start
flexingusb quick flash --iso /path/to/file.iso
```
```

6. Click "Publish release"

### Using GitHub CLI:
```bash
# Create release
gh release create v1.1.0 --title "FlexingUSB v1.1.0 - Enhanced Features" --notes-file RELEASE_NOTES.md
```

## Step 9: Update README with GitHub Links

Update the README.md to include your GitHub repository links:

```bash
# Replace the GitHub URLs in README.md with your actual repository
sed -i '' 's|https://github.com/Goenvim/FlexingUSB|https://github.com/YOUR_USERNAME/FlexingUSB|g' README.md
```

## Step 10: Verify Everything Works

```bash
# Test the installation process
cd /tmp
git clone https://github.com/YOUR_USERNAME/FlexingUSB.git
cd FlexingUSB
make install

# Test the commands
FlexingUSB --help
flexingusb --help
```

## Step 11: Optional - Create Installation Script

Create a simple installation script for users:

```bash
cat > install.sh << 'EOF'
#!/bin/bash
# FlexingUSB Installation Script

echo "🚀 Installing FlexingUSB..."

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Git is required but not installed."
    echo "Please install Git first: https://git-scm.com/downloads"
    exit 1
fi

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Swift is required but not installed."
    echo "Please install Xcode Command Line Tools: xcode-select --install"
    exit 1
fi

# Clone repository
echo "📥 Cloning FlexingUSB repository..."
git clone https://github.com/YOUR_USERNAME/FlexingUSB.git /tmp/FlexingUSB
cd /tmp/FlexingUSB

# Build and install
echo "🔨 Building FlexingUSB..."
make install

# Clean up
cd /
rm -rf /tmp/FlexingUSB

echo "✅ FlexingUSB installed successfully!"
echo "Usage: FlexingUSB --help or flexingusb --help"
EOF

chmod +x install.sh
```

## Step 12: Add Repository to Git and Push

```bash
# Add the installation script
git add install.sh
git commit -m "Add installation script for easy setup"
git push
```

## Step 13: Create a Simple Website (Optional)

Create a `docs/` folder with a simple website:

```bash
mkdir docs
cat > docs/index.md << 'EOF'
# FlexingUSB

A powerful, safe, and intelligent macOS command-line tool for writing ISO images to USB drives.

## Quick Install

```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/FlexingUSB/main/install.sh | bash
```

## Features

- ⚡ 3-5x faster than traditional methods
- 🛡️ Safety first - never touches internal drives
- 📊 Real-time progress with speed and ETA
- 🔍 Fake USB detection (Rufus-inspired)
- 📋 Detailed technical specifications
- 🚀 Quick operations for common tasks

## Usage

```bash
# Interactive workflow
flexingusb start

# Quick flash
flexingusb quick flash --iso /path/to/file.iso

# Show specifications
flexingusb specs --iso /path/to/file.iso
```

[View on GitHub](https://github.com/YOUR_USERNAME/FlexingUSB)
EOF

git add docs/
git commit -m "Add documentation website"
git push
```

## Step 14: Enable GitHub Pages (Optional)

1. Go to your repository settings
2. Scroll to "Pages" section
3. Source: "Deploy from a branch"
4. Branch: "main" / "docs"
5. Save

## Final Verification

Test everything works:

```bash
# Test installation from GitHub
cd /tmp
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/FlexingUSB/main/install.sh | bash

# Test commands
FlexingUSB --help
flexingusb --help
```

## Summary

Your FlexingUSB repository is now published with:

✅ **Repository**: `https://github.com/YOUR_USERNAME/FlexingUSB`  
✅ **Installation**: `curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/FlexingUSB/main/install.sh | bash`  
✅ **Documentation**: Complete README with all features  
✅ **Releases**: Tagged version v1.1.0  
✅ **Features**: Global launcher, technical specs, quick operations  

Users can now install and use FlexingUSB with:
```bash
git clone https://github.com/YOUR_USERNAME/FlexingUSB.git
cd FlexingUSB
make install
```

And use it from anywhere:
```bash
flexingusb start
flexingusb quick flash --iso /path/to/file.iso
```
