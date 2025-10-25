import ArgumentParser
import Foundation

struct FlexingUSB: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A Swift command-line tool to write ISO images to USB drives safely and easily.",
        discussion: """
        FlexingUSB helps you create bootable USB drives from ISO images.
        
        Safety features:
        - Never allows operations on internal disk (/dev/disk0)
        - Requires explicit confirmation before destructive operations
        - Verifies disk checksums after writing
        
        Example usage:
          FlexingUSB start           # Interactive ISO-to-USB workflow
          FlexingUSB list            # Show all external drives
          FlexingUSB restore         # Restore a USB to FAT32/exFAT
        """,
        subcommands: [Start.self, Restore.self, List.self, Verify.self, Specs.self, Quick.self]
    )
}

extension FlexingUSB {
    /// Main command: detect disks, select ISO, and flash
    struct Start: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Detects disks, prompts for an ISO, and flashes it to a USB drive.",
            discussion: "Interactive workflow for creating a bootable USB from an ISO image."
        )
        
        @Flag(name: .long, help: "Simulate actions without actually writing to disk")
        var dryRun = false
        
        @Flag(name: .long, help: "Skip verification after writing")
        var skipVerify = false

        func run() throws {
            UI.printHeader("FlexingUSB - ISO to USB Writer")
            
            // Step 1: Detect external disks
            UI.printMessage("Scanning for external disks...", color: .cyan)
            let diskManager = DiskManager()
            let disks = try diskManager.getExternalDisks()
            
            if disks.isEmpty {
                UI.printError("No external disks found. Please connect a USB drive.")
                throw ExitCode.failure
            }
            
            diskManager.displayExternalDisks(disks)
            
            // Step 2: Let user select a disk
            guard let selection = UI.promptNumber("Select target device", min: 1, max: disks.count) else {
                UI.printError("Invalid selection")
                throw ExitCode.failure
            }
            
            let selectedDisk = disks[selection - 1]
            print()
            UI.printMessage("Selected: \(selectedDisk.devicePath) - \(selectedDisk.displayName)", color: .green)
            print()
            
            // Step 2.5: Optional bad blocks check (Rufus-inspired)
            if UI.promptYesNo("Check USB for fake/counterfeit capacity? (Rufus-style check)", defaultYes: false) {
                let checker = BadBlockChecker(diskIdentifier: selectedDisk.DeviceIdentifier)
                _ = try checker.quickCapacityCheck()
                print()
            }
            
            // Step 3: Select ISO file
            print()
            UI.printMessage("Enter the path to your ISO file:", color: .cyan)
            UI.printMessage("(Tip: Drag and drop the ISO file here, or paste the path)", color: .white)
            print("ISO path: ", terminator: "")
            fflush(stdout)
            
            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                UI.printError("No path provided")
                throw ExitCode.failure
            }
            
            // Remove quotes if user dragged and dropped
            let isoPath = input.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
            
            print()
            UI.printMessage("Selected file: \(isoPath)", color: .green)
            
            // Step 4: Verify ISO exists and detect type
            let isoManager = ISOManager(isoPath: isoPath)
            try isoManager.verifyExists()
            
            let isoType = isoManager.detectType()
            let description = isoManager.getDescription()
            let sizeInGB = Double(try isoManager.getFileSize()) / 1_000_000_000
            
            UI.printMessage("Detected type: \(description)", color: .cyan)
            UI.printMessage("Size: \(String(format: "%.2f GB", sizeInGB))", color: .white)
            print()
            
            // Step 5: Optional Windows patching
            var finalISOPath = isoPath
            if isoType == .windows {
                if UI.promptYesNo("Would you like information about removing TPM 2.0 requirements?", defaultYes: false) {
                    finalISOPath = try isoManager.patchWindowsISO()
                }
            }
            
            // Step 6: Final confirmation
            UI.printHeader("Ready to Write")
            UI.printWarning("This will ERASE all data on \(selectedDisk.devicePath)")
            UI.printMessage("  Device: \(selectedDisk.devicePath)", color: .white)
            UI.printMessage("  Name: \(selectedDisk.displayName)", color: .white)
            UI.printMessage("  Size: \(String(format: "%.2f GB", selectedDisk.sizeInGB))", color: .white)
            UI.printMessage("  ISO: \(isoPath)", color: .white)
            print()
            
            if !UI.promptYesNo("Continue with write operation?", defaultYes: false) {
                UI.printWarning("Operation cancelled")
                throw ExitCode.failure
            }
            
            print()
            
            // Step 7: Write ISO to USB using DIRECT I/O (much faster!)
            let writer = Writer(isoPath: finalISOPath, diskIdentifier: selectedDisk.DeviceIdentifier)
            try writer.writeWithDirectIO(dryRun: dryRun)
            
            if dryRun {
                UI.printSuccess("Dry run completed successfully")
                return
            }
            
            // Step 8: Optional verification
            if !skipVerify {
                print()
                if UI.promptYesNo("Would you like to verify the written data?", defaultYes: true) {
                    try writer.verify()
                }
            }
            
            print()
            UI.printHeader("Success!")
            UI.printSuccess("USB drive is ready for use")
            UI.printMessage("You can now safely eject \(selectedDisk.devicePath)", color: .white)
        }
    }

    /// Restore command: format USB back to FAT32/exFAT
    struct Restore: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Restores a USB drive to a clean exFAT or FAT32 volume.",
            discussion: "Erases a USB drive and formats it as FAT32 (≤32GB) or exFAT (>32GB)."
        )
        
        @Option(name: .shortAndLong, help: "Format type (FAT32 or ExFAT)")
        var format: String?
        
        @Option(name: .shortAndLong, help: "Volume name")
        var name: String?

        func run() throws {
            UI.printHeader("Restore USB Drive")
            
            // Detect external disks
            UI.printMessage("Scanning for external disks...", color: .cyan)
            let diskManager = DiskManager()
            let disks = try diskManager.getExternalDisks()
            
            if disks.isEmpty {
                UI.printError("No external disks found")
                throw ExitCode.failure
            }
            
            diskManager.displayExternalDisks(disks)
            
            // Select disk
            guard let selection = UI.promptNumber("Select drive to restore", min: 1, max: disks.count) else {
                UI.printError("Invalid selection")
                throw ExitCode.failure
            }
            
            let selectedDisk = disks[selection - 1]
            print()
            
            // Determine format
            let finalFormat: String
            if let userFormat = format {
                finalFormat = userFormat
            } else if selectedDisk.sizeInGB > 32 {
                finalFormat = "ExFAT"
                UI.printMessage("Auto-selected ExFAT (disk > 32GB)", color: .cyan)
            } else {
                finalFormat = "FAT32"
                UI.printMessage("Auto-selected FAT32 (disk ≤ 32GB)", color: .cyan)
            }
            
            let volumeName = name ?? "Untitled"
            
            // Confirmation
            print()
            UI.printWarning("This will ERASE all data on \(selectedDisk.devicePath)")
            UI.printMessage("  Format: \(finalFormat)", color: .white)
            UI.printMessage("  Name: \(volumeName)", color: .white)
            print()
            
            if !UI.promptYesNo("Continue with format operation?", defaultYes: false) {
                UI.printWarning("Operation cancelled")
                throw ExitCode.failure
            }
            
            // Erase disk
            try diskManager.eraseDisk(selectedDisk.DeviceIdentifier, format: finalFormat, name: volumeName)
            
            print()
            UI.printSuccess("USB drive restored successfully!")
            UI.printMessage("Device \(selectedDisk.devicePath) is now formatted as \(finalFormat)", color: .white)
        }
    }

    /// List command: show all external drives
    struct List: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Lists all connected external USB drives.",
            discussion: "Shows device path, size, volume name, and file system for each external drive."
        )

        func run() throws {
            UI.printHeader("External Drives")
            
            let diskManager = DiskManager()
            let disks = try diskManager.getExternalDisks()
            
            if disks.isEmpty {
                UI.printWarning("No external disks found")
                return
            }
            
            diskManager.displayExternalDisks(disks)
            
            // Show detailed info
            for disk in disks {
                let sizeStr = String(format: "%.2f GB", disk.sizeInGB)
                UI.printMessage("Device: \(disk.devicePath)", color: .cyan)
                UI.printMessage("  Size: \(sizeStr)", color: .white)
                UI.printMessage("  Content: \(disk.Content)", color: .white)
                if let partitions = disk.Partitions {
                    for partition in partitions {
                        if let volName = partition.VolumeName {
                            UI.printMessage("  Volume: \(volName)", color: .white)
                        }
                        if let mountPoint = partition.MountPoint {
                            UI.printMessage("  Mounted: \(mountPoint)", color: .white)
                        }
                    }
                }
                print()
            }
        }
    }

    /// Verify command: check integrity of written ISO
    struct Verify: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Verifies the integrity of a previously written ISO on a USB drive.",
            discussion: "Compares checksums between an ISO file and a USB device."
        )
        
        @Argument(help: "Path to the ISO file used to write the USB")
        var isoPath: String
        
        @Argument(help: "Disk identifier (e.g., disk2)")
        var diskIdentifier: String

        func run() throws {
            UI.printHeader("Verify USB Drive")
            
            // Verify inputs
            let diskManager = DiskManager()
            try diskManager.verifySafeDisk(diskIdentifier)
            
            let isoManager = ISOManager(isoPath: isoPath)
            try isoManager.verifyExists()
            
            UI.printMessage("ISO: \(isoPath)", color: .white)
            UI.printMessage("USB: /dev/\(diskIdentifier)", color: .white)
            print()
            
            // Perform verification
            let writer = Writer(isoPath: isoPath, diskIdentifier: diskIdentifier)
            try writer.verify()
        }
    }
    
    /// Specs command: show detailed technical specifications
    struct Specs: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Shows detailed technical specifications for ISO files and USB drives.",
            discussion: "Displays comprehensive technical information about ISO files and USB drives."
        )
        
        @Option(name: .shortAndLong, help: "Path to ISO file for analysis")
        var iso: String?
        
        @Option(name: .shortAndLong, help: "USB disk identifier (e.g., disk2)")
        var usb: String?
        
        @Flag(name: .long, help: "Show all available specifications")
        var all = false

        func run() throws {
            UI.printHeader("Technical Specifications")
            
            if let isoPath = iso {
                try showISOSpecs(isoPath)
            }
            
            if let usbDisk = usb {
                try showUSBSpecs(usbDisk)
            }
            
            if all {
                try showAllSpecs()
            }
            
            if iso == nil && usb == nil && !all {
                UI.printMessage("Use --iso <path> to analyze an ISO file", color: .cyan)
                UI.printMessage("Use --usb <disk> to analyze a USB drive", color: .cyan)
                UI.printMessage("Use --all to show all available specifications", color: .cyan)
            }
        }
        
        private func showISOSpecs(_ isoPath: String) throws {
            UI.printHeader("ISO File Specifications")
            
            let isoManager = ISOManager(isoPath: isoPath)
            try isoManager.verifyExists()
            
            let specs = isoManager.getTechnicalSpecs()
            
            for (key, value) in specs {
                UI.printMessage("\(key): \(value)", color: .white)
            }
            print()
        }
        
        private func showUSBSpecs(_ diskIdentifier: String) throws {
            UI.printHeader("USB Drive Specifications")
            
            let diskManager = DiskManager()
            try diskManager.verifySafeDisk(diskIdentifier)
            
            let specs = try diskManager.getUSBTechnicalSpecs(diskIdentifier)
            
            for (key, value) in specs {
                UI.printMessage("\(key): \(value)", color: .white)
            }
            print()
        }
        
        private func showAllSpecs() throws {
            UI.printHeader("All Available Specifications")
            
            // Show all external drives
            let diskManager = DiskManager()
            let disks = try diskManager.getExternalDisks()
            
            if disks.isEmpty {
                UI.printWarning("No external drives found")
                return
            }
            
            for disk in disks {
                UI.printMessage("USB Drive: \(disk.devicePath)", color: .cyan)
                let specs = try diskManager.getUSBTechnicalSpecs(disk.DeviceIdentifier)
                for (key, value) in specs {
                    UI.printMessage("  \(key): \(value)", color: .white)
                }
                print()
            }
        }
    }
    
    /// Quick command: fast operations for common tasks
    struct Quick: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Quick operations for common ISO-to-USB tasks.",
            discussion: "Provides fast shortcuts for common operations like quick flash, restore, and info."
        )
        
        @Argument(help: "Quick operation: flash, restore, info, or status")
        var operation: String
        
        @Option(name: .shortAndLong, help: "ISO file path (for flash operation)")
        var iso: String?
        
        @Option(name: .shortAndLong, help: "USB disk identifier (e.g., disk2)")
        var usb: String?

        func run() throws {
            switch operation.lowercased() {
            case "flash":
                try quickFlash()
            case "restore":
                try quickRestore()
            case "info":
                try quickInfo()
            case "status":
                try quickStatus()
            default:
                UI.printError("Unknown operation: \(operation)")
                UI.printMessage("Available operations: flash, restore, info, status", color: .cyan)
                throw ExitCode.failure
            }
        }
        
        private func quickFlash() throws {
            guard let isoPath = iso else {
                UI.printError("ISO path required for flash operation")
                UI.printMessage("Usage: FlexingUSB quick flash --iso /path/to/file.iso", color: .cyan)
                throw ExitCode.failure
            }
            
            UI.printHeader("Quick Flash")
            UI.printMessage("Flashing \(isoPath) to USB...", color: .cyan)
            
            // Get first available USB drive
            let diskManager = DiskManager()
            let disks = try diskManager.getExternalDisks()
            
            if disks.isEmpty {
                UI.printError("No external drives found")
                throw ExitCode.failure
            }
            
            let selectedDisk = disks.first!
            UI.printMessage("Using: \(selectedDisk.devicePath)", color: .green)
            
            // Quick confirmation
            if !UI.promptYesNo("Continue with quick flash?", defaultYes: true) {
                UI.printWarning("Operation cancelled")
                throw ExitCode.failure
            }
            
            // Flash the ISO
            let writer = Writer(isoPath: isoPath, diskIdentifier: selectedDisk.DeviceIdentifier)
            try writer.writeWithDirectIO(dryRun: false)
            
            UI.printSuccess("Quick flash completed!")
        }
        
        private func quickRestore() throws {
            UI.printHeader("Quick Restore")
            UI.printMessage("Restoring USB to FAT32/exFAT...", color: .cyan)
            
            let diskManager = DiskManager()
            let disks = try diskManager.getExternalDisks()
            
            if disks.isEmpty {
                UI.printError("No external drives found")
                throw ExitCode.failure
            }
            
            let selectedDisk = disks.first!
            UI.printMessage("Using: \(selectedDisk.devicePath)", color: .green)
            
            // Quick confirmation
            if !UI.promptYesNo("Continue with quick restore?", defaultYes: true) {
                UI.printWarning("Operation cancelled")
                throw ExitCode.failure
            }
            
            // Restore the USB
            let format = selectedDisk.sizeInGB > 32 ? "ExFAT" : "FAT32"
            try diskManager.eraseDisk(selectedDisk.DeviceIdentifier, format: format, name: "Untitled")
            
            UI.printSuccess("Quick restore completed!")
        }
        
        private func quickInfo() throws {
            UI.printHeader("Quick Info")
            
            let diskManager = DiskManager()
            let disks = try diskManager.getExternalDisks()
            
            if disks.isEmpty {
                UI.printWarning("No external drives found")
                return
            }
            
            for disk in disks {
                UI.printMessage("USB: \(disk.devicePath)", color: .cyan)
                UI.printMessage("  Size: \(String(format: "%.2f GB", disk.sizeInGB))", color: .white)
                UI.printMessage("  Name: \(disk.displayName)", color: .white)
                UI.printMessage("  Type: \(disk.Content)", color: .white)
            }
        }
        
        private func quickStatus() throws {
            UI.printHeader("Quick Status")
            
            let diskManager = DiskManager()
            let disks = try diskManager.getExternalDisks()
            
            UI.printMessage("External drives: \(disks.count)", color: .cyan)
            
            if let isoPath = iso {
                let isoManager = ISOManager(isoPath: isoPath)
                do {
                    try isoManager.verifyExists()
                    let size = try isoManager.getFileSize()
                    let sizeGB = Double(size) / 1_000_000_000
                    UI.printMessage("ISO: \(isoPath) (\(String(format: "%.2f GB", sizeGB)))", color: .green)
                } catch {
                    UI.printMessage("ISO: \(isoPath) (not found)", color: .red)
                }
            }
        }
    }
}

// Traditional entry point
FlexingUSB.main()

