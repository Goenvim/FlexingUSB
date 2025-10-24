# Publishing to GitHub

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `FlexingUSB`
3. Description: `A macOS command-line utility for safely writing ISO images to USB drives`
4. Public repository
5. Do NOT initialize with README (we already have one)
6. Click "Create repository"

## Step 2: Push to GitHub

Replace `yourusername` with your actual GitHub username:

```bash
# Add remote
git remote add origin https://github.com/yourusername/FlexingUSB.git

# Push code
git push -u origin main
```

## Step 3: Create Release

1. Go to your repository on GitHub
2. Click "Releases" → "Create a new release"
3. Tag: `v1.0.0`
4. Title: `FlexingUSB v1.0.0`
5. Description:

```
Initial release of FlexingUSB.

A macOS command-line utility for safely writing ISO images to USB drives.

**Features:**
- Safe disk operations with multiple validation layers
- Automatic ISO type detection (Windows, Linux, macOS)
- SHA256 verification
- Interactive terminal interface
- Native macOS file picker integration
- USB restoration to FAT32/exFAT

**Installation:**
```bash
git clone https://github.com/yourusername/FlexingUSB.git
cd FlexingUSB
make install
```

**Usage:**
```bash
FlexingUSB start    # Create bootable USB
FlexingUSB list     # List external drives
FlexingUSB restore  # Restore USB drive
```

See the [README](https://github.com/yourusername/FlexingUSB#readme) for full documentation.
```

6. Click "Publish release"

## Step 4: Update Repository Settings

1. Go to Settings → General
2. Add topics: `swift`, `macos`, `cli`, `usb`, `iso`
3. Enable issues and discussions
4. Go to Settings → Actions → General
5. Enable GitHub Actions

## Done!

Your repository is now live at:
`https://github.com/yourusername/FlexingUSB`
