# GitHub Setup Instructions

## Step 1: Create the Repository

1. Go to https://github.com/Goenvim
2. Click the "+" icon → "New repository"
3. Repository name: **FlexingUSB**
4. Description: **A macOS command-line utility for safely writing ISO images to USB drives**
5. Select **Public**
6. Do NOT initialize with README, .gitignore, or license (we already have these)
7. Click "Create repository"

## Step 2: Push Your Code

After creating the repository, run these commands:

### Using HTTPS (with Personal Access Token)

```bash
cd /Users/romangrzadziel/Documents/FlexingUSB

# Push to GitHub
git push -u origin main
```

You'll be prompted for credentials:
- Username: `Goenvim`
- Password: Use a **Personal Access Token** (not your GitHub password)

To create a Personal Access Token:
1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Name: "FlexingUSB"
4. Expiration: 90 days (or your preference)
5. Select scope: **repo** (full control of private repositories)
6. Click "Generate token"
7. Copy the token and use it as your password

### Using SSH (recommended for future pushes)

```bash
# Remove HTTPS remote
git remote remove origin

# Add SSH remote
git remote add origin git@github.com:Goenvim/FlexingUSB.git

# Push
git push -u origin main
```

For SSH, you need to:
1. Generate SSH key: `ssh-keygen -t ed25519 -C "your_email@example.com"`
2. Add to ssh-agent: `ssh-add ~/.ssh/id_ed25519`
3. Add public key to GitHub: https://github.com/settings/keys

## Step 3: Create Release (After Push)

Once pushed successfully:

1. Go to https://github.com/Goenvim/FlexingUSB
2. Click "Releases" → "Create a new release"
3. Tag: `v1.0.0`
4. Target: `main`
5. Title: **FlexingUSB v1.0.0**
6. Description:

```markdown
Initial release of FlexingUSB.

## Features

- Safe disk operations with multiple validation layers
- Automatic ISO type detection (Windows, Linux, macOS)
- SHA256 verification
- Interactive terminal interface
- Native macOS file picker integration
- USB restoration to FAT32/exFAT

## Installation

```bash
git clone https://github.com/Goenvim/FlexingUSB.git
cd FlexingUSB
make install
```

## Quick Start

```bash
FlexingUSB start    # Create bootable USB
FlexingUSB list     # List external drives
FlexingUSB restore  # Restore USB drive
```

See the [README](https://github.com/Goenvim/FlexingUSB#readme) for full documentation.
```

7. Click "Publish release"

## Step 4: Repository Settings

1. Add topics: `swift`, `macos`, `cli`, `usb`, `iso`, `bootable-usb`
2. Enable Discussions (Settings → Features)
3. Enable Issues (Settings → Features)

## Done!

Your repository will be live at:
**https://github.com/Goenvim/FlexingUSB**
