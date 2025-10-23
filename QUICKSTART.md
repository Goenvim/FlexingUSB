# FlexingUSB Quick Start Guide

Get up and running with FlexingUSB in 5 minutes!

## Installation (2 minutes)

```bash
# Clone the repository
git clone https://github.com/yourusername/FlexingUSB.git
cd FlexingUSB

# Build and install
make install
```

You'll be prompted for your password (sudo required).

## First Use (3 minutes)

### Step 1: Check Installation

```bash
FlexingUSB --help
```

Expected output: Help information with available commands.

### Step 2: List Your Drives

```bash
FlexingUSB list
```

**No USB connected?** Connect a USB drive now.

### Step 3: Try Dry Run

```bash
FlexingUSB start --dry-run
```

This simulates the entire process without writing anything:
1. Shows your external drives
2. Opens file picker (you can cancel)
3. Shows what commands would run
4. **Nothing is written to disk**

### Step 4: Create Your First Bootable USB

**[WARNING] WARNING**: This will erase all data on the USB!

```bash
FlexingUSB start
```

Follow the prompts:
1. **Select your USB drive** - Choose the number
2. **Select ISO file** - Use Finder to pick your ISO
3. **Confirm** - Type `CONFIRM` (all caps)
4. **Wait** - The write process may take 5-15 minutes
5. **Verify** - Answer `y` to verify (recommended)

### Step 5: Restore USB When Done

After using your bootable USB, restore it:

```bash
FlexingUSB restore
```

Your USB is now back to normal!

## Common First-Time Questions

### Q: Will this erase my Mac's hard drive?

**A: No!** FlexingUSB has multiple safety checks:
- Never touches `/dev/disk0` (your internal drive)
- Only shows external USB drives
- Requires explicit confirmation
- You can test with `--dry-run`

### Q: What if I select the wrong USB?

**A:** Before writing, you'll see:
```
[WARNING]  This will ERASE all data on /dev/disk2
  Device: /dev/disk2
  Name: Kingston DataTraveler
  Size: 32.00 GB
```

Verify this information carefully before typing `CONFIRM`.

### Q: How long does it take?

**A:** Typical times:
- Small ISO (1-2GB): 3-5 minutes
- Medium ISO (4-5GB): 8-12 minutes
- Large ISO (8GB+): 15-20 minutes

Depends on USB speed and ISO size.

### Q: Can I use the USB for files again later?

**A:** Yes! Use `FlexingUSB restore` to format it back to FAT32/exFAT.

### Q: What ISOs are supported?

**A:** All standard ISO files:
- Linux distros (Ubuntu, Fedora, Debian, etc.)
- Windows installers (Win10, Win11)
- macOS installers
- Any bootable ISO image

## Quick Reference Card

```bash
# List drives
FlexingUSB list

# Create bootable USB (interactive)
FlexingUSB start

# Test without writing
FlexingUSB start --dry-run

# Create bootable USB (skip verification)
FlexingUSB start --skip-verify

# Restore USB to normal
FlexingUSB restore

# Restore with custom settings
FlexingUSB restore --format ExFAT --name "MyUSB"

# Verify an existing USB
FlexingUSB verify /path/to/image.iso disk2

# Get help
FlexingUSB --help
FlexingUSB start --help
```

## Troubleshooting

### "No external disks found"

**Solution**: 
1. Connect your USB drive
2. Wait 5 seconds
3. Try `FlexingUSB list` again

### "Permission denied"

**Solution**: 
- FlexingUSB needs sudo for disk operations
- You'll be prompted for your password
- Make sure you're an admin on your Mac

### "Command not found"

**Solution**:
```bash
# Check if installed
which FlexingUSB

# If not found, add to PATH
export PATH="/usr/local/bin:$PATH"

# Or reinstall
cd FlexingUSB
make install
```

## Example Session

Here's what a typical session looks like:

```bash
$ FlexingUSB start

═══ FlexingUSB - ISO to USB Writer ═══

Scanning for external disks...

Detected external drives:
[1] /dev/disk2 - 32.00GB Kingston (GUID_partition_scheme)

Select target device (1–1): 1

Selected: /dev/disk2 - Kingston

Opening Finder to select ISO file...
Selected file: /Users/me/Downloads/ubuntu-22.04.iso
Detected type: Linux distribution image
Size: 4.69 GB

═══ Ready to Write ═══
[WARNING]  This will ERASE all data on /dev/disk2
  Device: /dev/disk2
  Name: Kingston
  Size: 32.00 GB
  ISO: /Users/me/Downloads/ubuntu-22.04.iso

[WARNING]  Type 'CONFIRM' to continue, or anything else to cancel.
> CONFIRM

Writing ISO to USB using dd...
[WARNING]  This may take several minutes. Please be patient.

| Writing... (elapsed: 284s)
Syncing disk...
[OK] Write complete!

Would you like to verify the written data? [Y/n]: y

═══ Verifying written data ═══
Calculating ISO checksum...
Hashing ISO: [████████████████████] 100.0% (4690.0MB / 4690.0MB)
ISO SHA256: a4e7b84c3f72d8b9...

Reading from USB to verify...
Hashing USB: [████████████████████] 100.0% (4690.0MB / 4690.0MB)
USB SHA256: a4e7b84c3f72d8b9...

[OK] Verification passed! USB matches ISO perfectly.

═══ Success! ═══
[OK] USB drive is ready for use
You can now safely eject /dev/disk2
```

## Safety Tips

1. [OK] **Always back up important data** before using any USB
2. [OK] **Double-check disk selection** before confirming
3. [OK] **Use dry-run mode** if uncertain: `--dry-run`
4. [OK] **Verify downloads** - Check ISO checksums from official sources
5. [OK] **Test first** - Try with a spare USB before important ones

## What's Next?

Once you're comfortable:

1. **Read full docs**: Check out [README.md](README.md)
2. **See examples**: Explore [EXAMPLES.md](EXAMPLES.md)
3. **Contribute**: Read [CONTRIBUTING.md](CONTRIBUTING.md)
4. **Report issues**: Use GitHub Issues for bugs

## Support

- **Questions**: GitHub Discussions
- **Bugs**: GitHub Issues
- **Security**: See [SECURITY.md](SECURITY.md)

---

**That's it! You're ready to create bootable USB drives safely.** 

For detailed usage and advanced scenarios, see the full [README.md](README.md).
