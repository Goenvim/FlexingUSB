# FlexingUSB Usage Examples

This document provides real-world examples of using FlexingUSB for various scenarios.

---

## Table of Contents

- [Creating a Linux Bootable USB](#creating-a-linux-bootable-usb)
- [Creating a Windows Installation USB](#creating-a-windows-installation-usb)
- [Creating a macOS Installer USB](#creating-a-macos-installer-usb)
- [Verifying a Written USB](#verifying-a-written-usb)
- [Restoring a USB Drive](#restoring-a-usb-drive)
- [Using Dry Run Mode](#using-dry-run-mode)
- [Advanced Scenarios](#advanced-scenarios)

---

## Creating a Linux Bootable USB

### Ubuntu Desktop

```bash
# Download Ubuntu ISO from ubuntu.com
# Connect your USB drive (at least 8GB)

$ FlexingUSB start

═══ FlexingUSB - ISO to USB Writer ═══

Scanning for external disks...

Detected external drives:
[1] /dev/disk2 - 32.00GB Kingston DataTraveler (GUID_partition_scheme)

Select target device (1–1): 1

Selected: /dev/disk2 - Kingston DataTraveler

Opening Finder to select ISO file...
# [Select ubuntu-22.04.3-desktop-amd64.iso from Finder]

Selected file: /Users/user/Downloads/ubuntu-22.04.3-desktop-amd64.iso
Detected type: Linux distribution image
Size: 4.69 GB

═══ Ready to Write ═══
[WARNING]  This will ERASE all data on /dev/disk2
  Device: /dev/disk2
  Name: Kingston DataTraveler
  Size: 32.00 GB
  ISO: /Users/user/Downloads/ubuntu-22.04.3-desktop-amd64.iso

[WARNING]  Type 'CONFIRM' to continue, or anything else to cancel.
> CONFIRM

Writing ISO to USB using dd...
[WARNING]  This may take several minutes. Please be patient.

| Writing... (elapsed: 284s)
Syncing disk...
[OK] Write complete!

Would you like to verify the written data? [Y/n]: y

═══ Verifying written data ═══
...
[OK] Verification passed! USB matches ISO perfectly.

═══ Success! ═══
[OK] USB drive is ready for use
You can now safely eject /dev/disk2
```

### Fedora Workstation

```bash
$ FlexingUSB start

# Select Fedora ISO through Finder
# Follow same steps as Ubuntu
# Boot your computer from USB and install Fedora
```

---

## Creating a Windows Installation USB

### Windows 11

```bash
# Download Windows 11 ISO from Microsoft
# Connect USB drive (at least 8GB)

$ FlexingUSB start

# ... disk selection ...

Selected file: /Users/user/Downloads/Win11_English_x64.iso
Detected type: Windows installation image
Size: 5.23 GB

Would you like information about removing TPM 2.0 requirements? [y/N]: y

[WARNING]  Windows ISO patching is experimental.
This would typically involve:
  1. Mounting the ISO
  2. Copying contents to temp directory
  3. Modifying install.wim or boot.wim
  4. Rebuilding the ISO

For now, we'll use the original ISO.
To bypass TPM requirements on Windows 11, you can:
  - Use Rufus on Windows with TPM bypass option
  - Press Shift+F10 during install and modify registry

═══ Ready to Write ═══
# ... confirmation and write process ...
```

**Post-Installation TPM Bypass:**

During Windows 11 installation from the USB:
1. Press `Shift + F10` to open Command Prompt
2. Type `regedit` and press Enter
3. Navigate to `HKEY_LOCAL_MACHINE\SYSTEM\Setup`
4. Create a new key called `LabConfig`
5. Inside LabConfig, create DWORD values:
   - `BypassTPMCheck` = 1
   - `BypassSecureBootCheck` = 1
   - `BypassRAMCheck` = 1
6. Close Registry Editor and continue installation

---

## Creating a macOS Installer USB

### macOS Sonoma

```bash
# First, create an ISO from the installer app
# (Download from App Store first)

$ hdiutil create -o ~/macOS-Sonoma.dmg -size 16g -volname Sonoma -layout SPUD -fs HFS+J
$ hdiutil attach ~/macOS-Sonoma.dmg -noverify -mountpoint /Volumes/Sonoma
$ sudo /Applications/Install\ macOS\ Sonoma.app/Contents/Resources/createinstallmedia --volume /Volumes/Sonoma --nointeraction
$ hdiutil detach /Volumes/Install\ macOS\ Sonoma
$ hdiutil convert ~/macOS-Sonoma.dmg -format UDTO -o ~/macOS-Sonoma.cdr
$ mv ~/macOS-Sonoma.cdr ~/macOS-Sonoma.iso

# Now use FlexingUSB
$ FlexingUSB start

# Select the macOS-Sonoma.iso
# Follow the prompts
```

**Alternative:** Use Apple's built-in `createinstallmedia` tool directly without FlexingUSB.

---

## Verifying a Written USB

### After Writing

```bash
# If you skipped verification during write:
$ FlexingUSB verify ~/Downloads/ubuntu-22.04.iso disk2

═══ Verify USB Drive ═══

ISO: /Users/user/Downloads/ubuntu-22.04.iso
USB: /dev/disk2

═══ Verifying written data ═══
Calculating ISO checksum...
Hashing ISO: [████████████████████] 100.0% (4690.0MB / 4690.0MB)
ISO SHA256: a4e7b84c3f72d8b9e5f1c2d3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3

Reading from USB to verify...
Hashing USB: [████████████████████] 100.0% (4690.0MB / 4690.0MB)
USB SHA256: a4e7b84c3f72d8b9e5f1c2d3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3

[OK] Verification passed! USB matches ISO perfectly.
```

---

## Restoring a USB Drive

### After Using as Bootable USB

```bash
# Your USB now has unusual partitions and isn't recognized properly
$ FlexingUSB restore

═══ Restore USB Drive ═══

Scanning for external disks...

Detected external drives:
[1] /dev/disk2 - 32.00GB Kingston DataTraveler (GUID_partition_scheme)

Select drive to restore (1–1): 1

Auto-selected FAT32 (disk ≤ 32GB)

[WARNING]  This will ERASE all data on /dev/disk2
  Format: FAT32
  Name: Untitled

[WARNING]  Type 'CONFIRM' to continue, or anything else to cancel.
> CONFIRM

Erasing disk disk2 as FAT32...
Started erase on disk2
Unmounting disk
Creating the partition map
Waiting for partitions to activate
Formatting disk2s2 as MS-DOS (FAT32) with name Untitled
...
Finished erase on disk2

[OK] USB drive restored successfully!
Device /dev/disk2 is now formatted as FAT32
```

### Custom Format and Name

```bash
# Restore with ExFAT and custom name
$ FlexingUSB restore --format ExFAT --name "MyUSB"

# Restore a large USB (>32GB) with auto-detected ExFAT
$ FlexingUSB restore
Auto-selected ExFAT (disk > 32GB)
```

---

## Using Dry Run Mode

### Test Before Writing

```bash
# Preview what will happen without actually writing
$ FlexingUSB start --dry-run

# ... go through all the prompts ...

[DRY RUN] Would execute:
sudo dd if=/Users/user/Downloads/ubuntu.iso of=/dev/rdisk2 bs=1m

[OK] Dry run completed successfully
```

**Benefits:**
- Test disk detection without risk
- Verify file picker works
- Check ISO detection
- See exact commands that would run
- Perfect for testing on systems without spare USB drives

---

## Advanced Scenarios

### Scripting (Non-Interactive Mode)

FlexingUSB is designed to be interactive for safety, but you can prepare inputs:

```bash
# Use printf to simulate user input
printf "1\nCONFIRM\nn\n" | FlexingUSB start
```

**Warning:** Scripting bypasses safety features. Use with extreme caution!

### Multiple ISOs to Multiple USBs

```bash
# Write different ISOs to different drives sequentially
$ FlexingUSB start  # First USB with Ubuntu
$ FlexingUSB start  # Second USB with Windows
$ FlexingUSB start  # Third USB with Fedora
```

### Checking Available Disks

```bash
# Quick disk check
$ FlexingUSB list

═══ External Drives ═══

Detected external drives:
[1] /dev/disk2 - 32.00GB Kingston (GUID_partition_scheme)
[2] /dev/disk3 - 64.00GB SanDisk (GUID_partition_scheme)

Device: /dev/disk2
  Size: 32.00 GB
  Content: GUID_partition_scheme
  Volume: Kingston
  Mounted: /Volumes/Kingston

Device: /dev/disk3
  Size: 64.00 GB
  Content: GUID_partition_scheme
  Volume: SanDisk
  Mounted: /Volumes/SanDisk
```

### Skip Verification (Faster)

```bash
# Skip verification to save time (not recommended for important data)
$ FlexingUSB start --skip-verify
```

### Verify Old USB

```bash
# You wrote a USB weeks ago, verify it's still good
$ FlexingUSB verify ~/Downloads/old-ubuntu.iso disk2

# If verification fails, the USB may be corrupted
# Re-write the ISO
```

---

## Tips and Best Practices

### 1. Always Verify Important USB Drives

```bash
# For critical bootable USBs, always verify
FlexingUSB start
# Answer 'y' to verification prompt
```

### 2. Use Dry Run When Unsure

```bash
# Test first
FlexingUSB start --dry-run

# If everything looks good, run for real
FlexingUSB start
```

### 3. Label Your USBs Physically

After creating a bootable USB, use a physical label:
- "Ubuntu 22.04 Install"
- "Windows 11 Installer"
- "macOS Sonoma Recovery"

### 4. Keep ISOs Organized

```bash
# Organized directory structure
~/ISOs/
  ├── Linux/
  │   ├── ubuntu-22.04.iso
  │   ├── fedora-38.iso
  │   └── debian-12.iso
  ├── Windows/
  │   ├── Win11.iso
  │   └── Win10.iso
  └── macOS/
      └── Sonoma.iso
```

### 5. Restore After Use

Always restore bootable USBs when done:

```bash
FlexingUSB restore
```

This prevents confusion and makes the USB usable for normal files.

---

## Troubleshooting Examples

### ISO Won't Write

```bash
$ FlexingUSB start
# If write fails, try:
# 1. Ensure USB isn't write-protected
# 2. Try a different USB port
# 3. Try a different USB drive
# 4. Check ISO integrity (redownload)
```

### Verification Fails

```bash
$ FlexingUSB verify ~/Downloads/ubuntu.iso disk2
[ERROR] Error: Verification failed: USB content doesn't match ISO

# Solution: Write again
$ FlexingUSB start
# Select same ISO and USB, write again
```

### USB Not Detected

```bash
$ FlexingUSB list
[WARNING]  No external disks found

# Check:
# 1. USB is properly connected
# 2. Try different USB port
# 3. Check in Disk Utility
# 4. Try another USB drive
```

---

## Real-World Use Cases

### System Administrator

```bash
# Maintain multiple bootable USBs for different purposes
USB1: Ubuntu 22.04 LTS (support)
USB2: Windows 11 (client installs)
USB3: Fedora 38 (development)
USB4: System rescue tools
```

### Software Developer

```bash
# Test OS compatibility
1. Write Ubuntu ISO
2. Test application
3. Restore USB
4. Write Fedora ISO
5. Test application
6. Repeat for other distros
```

### IT Education

```bash
# Create bootable USBs for students
$ FlexingUSB start --dry-run  # Demonstrate first
$ FlexingUSB start            # Create actual USB
$ FlexingUSB list             # Show result
```

---

**More examples and scenarios coming soon!**

For more help, see:
- [README.md](README.md) - Full documentation
- [INSTALL.md](INSTALL.md) - Installation guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contributing guidelines
