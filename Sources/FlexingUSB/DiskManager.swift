import Foundation

/// Represents partition information for a disk
struct PartitionInfo: Codable {
    let MountPoint: String?
    let VolumeName: String?
    let VolumeUUID: String?
    let Content: String?
}

/// Represents detailed disk information
struct DiskInfo: Codable {
    let DeviceIdentifier: String
    let Size: Int
    let Content: String
    let Partitions: [PartitionInfo]?
    
    var displayName: String {
        let volumeName = Partitions?.first?.VolumeName ?? "Unnamed"
        return volumeName
    }
    
    var sizeInGB: Double {
        return Double(Size) / 1_000_000_000
    }
    
    var devicePath: String {
        return "/dev/\(DeviceIdentifier)"
    }
}

/// Represents the output of diskutil list
struct DiskUtilList: Codable {
    let AllDisks: [String]
    let AllDisksAndPartitions: [DiskInfo]
}

/// Errors specific to disk operations
enum DiskError: Error, LocalizedError {
    case internalDiskNotAllowed
    case diskNotFound
    case unmountFailed
    case invalidDiskIdentifier
    case noExternalDisksFound
    
    var errorDescription: String? {
        switch self {
        case .internalDiskNotAllowed:
            return "Internal disk operations are not allowed for safety reasons"
        case .diskNotFound:
            return "The specified disk was not found"
        case .unmountFailed:
            return "Failed to unmount the disk"
        case .invalidDiskIdentifier:
            return "Invalid disk identifier"
        case .noExternalDisksFound:
            return "No external disks were found"
        }
    }
}

/// Manages disk detection, verification, and operations
class DiskManager {
    
    /// Get all external disks connected to the system
    func getExternalDisks() throws -> [DiskInfo] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
        process.arguments = ["list", "-plist", "external"]
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "DiskManager", code: Int(process.terminationStatus), 
                         userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let decoder = PropertyListDecoder()
        let diskutilList = try decoder.decode(DiskUtilList.self, from: data)
        
        // Filter to get only whole disks (not partitions)
        // Partitions have format like "disk2s1", whole disks are just "disk2"
        let disks = diskutilList.AllDisksAndPartitions.filter { disk in
            let id = disk.DeviceIdentifier
            // Check if it matches pattern diskN (not diskNsM)
            return id.range(of: "^disk[0-9]+$", options: .regularExpression) != nil
        }
        
        return disks
    }
    
    /// Verify that a disk identifier is safe to use (not internal disk)
    func verifySafeDisk(_ diskIdentifier: String) throws {
        // Never allow disk0 (internal macOS disk)
        if diskIdentifier == "disk0" || diskIdentifier.hasPrefix("disk0s") {
            throw DiskError.internalDiskNotAllowed
        }
        
        // Verify disk is external
        let externalDisks = try getExternalDisks()
        guard externalDisks.contains(where: { $0.DeviceIdentifier == diskIdentifier }) else {
            throw DiskError.diskNotFound
        }
    }
    
    /// Unmount all partitions on a disk
    func unmountDisk(_ diskIdentifier: String) throws {
        try verifySafeDisk(diskIdentifier)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
        process.arguments = ["unmountDisk", "force", diskIdentifier]
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            UI.printWarning("Unmount warning: \(errorMessage)")
            // Don't throw - unmount warnings are often non-fatal
        }
    }
    
    /// Get detailed information about a specific disk
    func getDiskInfo(_ diskIdentifier: String) throws -> DiskInfo {
        let externalDisks = try getExternalDisks()
        guard let diskInfo = externalDisks.first(where: { $0.DeviceIdentifier == diskIdentifier }) else {
            throw DiskError.diskNotFound
        }
        return diskInfo
    }
    
    /// Erase a disk with the specified format
    func eraseDisk(_ diskIdentifier: String, format: String = "ExFAT", name: String = "Untitled") throws {
        try verifySafeDisk(diskIdentifier)
        
        UI.printMessage("Erasing disk \(diskIdentifier) as \(format)...", color: .cyan)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
        process.arguments = ["eraseDisk", format, name, diskIdentifier]
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "DiskManager", code: Int(process.terminationStatus),
                         userInfo: [NSLocalizedDescriptionKey: "Failed to erase disk: \(errorMessage)"])
        }
        
        let output = pipe.fileHandleForReading.readDataToEndOfFile()
        if let outputStr = String(data: output, encoding: .utf8) {
            UI.printMessage(outputStr, color: .white)
        }
    }
    
    /// Display all external disks in a user-friendly format
    func displayExternalDisks(_ disks: [DiskInfo]) {
        UI.printMessage("\nDetected external drives:", color: .cyan)
        for (index, disk) in disks.enumerated() {
            let sizeStr = String(format: "%.2fGB", disk.sizeInGB)
            let volumeName = disk.displayName
            UI.printMessage("[\(index + 1)] \(disk.devicePath) - \(sizeStr) \(volumeName) (\(disk.Content))")
        }
        print()
    }
    
    /// Get detailed technical specifications of a USB drive
    func getUSBTechnicalSpecs(_ diskIdentifier: String) throws -> [String: String] {
        var specs: [String: String] = [:]
        
        do {
            let diskInfo = try getDiskInfo(diskIdentifier)
            
            // Basic information
            specs["Device Path"] = diskInfo.devicePath
            specs["Device Identifier"] = diskInfo.DeviceIdentifier
            specs["Size"] = formatBytes(Int64(diskInfo.Size))
            specs["Content Type"] = diskInfo.Content
            
            // USB-specific information
            specs["USB Speed"] = detectUSBSpeed(diskIdentifier)
            specs["USB Version"] = detectUSBVersion(diskIdentifier)
            specs["Connection Type"] = "USB"
            
            // Partition information
            if let partitions = diskInfo.Partitions {
                specs["Partition Count"] = "\(partitions.count)"
                for (index, partition) in partitions.enumerated() {
                    if let volumeName = partition.VolumeName {
                        specs["Volume \(index + 1)"] = volumeName
                    }
                    if let mountPoint = partition.MountPoint {
                        specs["Mount Point \(index + 1)"] = mountPoint
                    }
                    if let content = partition.Content {
                        specs["Content \(index + 1)"] = content
                    }
                }
            }
            
            // Performance information
            specs["Write Speed"] = estimateWriteSpeed(diskInfo.sizeInGB)
            specs["Estimated Write Time"] = estimateWriteTime(diskInfo.sizeInGB)
            
            // Safety information
            specs["Safety Status"] = "External Drive (Safe)"
            specs["Internal Disk"] = "No"
            
        } catch {
            specs["Error"] = "Failed to read disk information: \(error.localizedDescription)"
        }
        
        return specs
    }
    
    /// Format bytes into human-readable format
    private func formatBytes(_ bytes: Int64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var size = Double(bytes)
        var unitIndex = 0
        
        while size >= 1024 && unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }
        
        return String(format: "%.2f %s", size, units[unitIndex])
    }
    
    /// Detect USB speed based on device information
    private func detectUSBSpeed(_ diskIdentifier: String) -> String {
        do {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")
            process.arguments = ["info", diskIdentifier]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                if output.contains("USB 3.0") || output.contains("USB 3.1") || output.contains("USB 3.2") {
                    return "USB 3.0+ (High Speed)"
                } else if output.contains("USB 2.0") {
                    return "USB 2.0 (Full Speed)"
                } else if output.contains("USB 1.1") {
                    return "USB 1.1 (Low Speed)"
                }
            }
        } catch {
            // Silent failure
        }
        return "Unknown"
    }
    
    /// Detect USB version
    private func detectUSBVersion(_ diskIdentifier: String) -> String {
        do {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/system_profiler")
            process.arguments = ["SPUSBDataType"]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                // Look for USB version information
                if output.contains("USB 3.0") {
                    return "USB 3.0"
                } else if output.contains("USB 2.0") {
                    return "USB 2.0"
                } else if output.contains("USB 1.1") {
                    return "USB 1.1"
                }
            }
        } catch {
            // Silent failure
        }
        return "Unknown"
    }
    
    /// Estimate write speed based on USB drive size and type
    private func estimateWriteSpeed(_ sizeInGB: Double) -> String {
        if sizeInGB >= 64 {
            return "30-50 MB/s (USB 3.0+)"
        } else if sizeInGB >= 16 {
            return "20-40 MB/s (USB 3.0)"
        } else {
            return "10-20 MB/s (USB 2.0)"
        }
    }
    
    /// Estimate write time for a typical 4GB ISO
    private func estimateWriteTime(_ sizeInGB: Double) -> String {
        let isoSizeGB = 4.0 // Typical ISO size
        let writeSpeedMBps = sizeInGB >= 32 ? 40.0 : 20.0 // Conservative estimate
        
        let timeInSeconds = (isoSizeGB * 1024) / writeSpeedMBps
        let minutes = Int(timeInSeconds / 60)
        let seconds = Int(timeInSeconds.truncatingRemainder(dividingBy: 60))
        
        return "\(minutes)m \(seconds)s (for 4GB ISO)"
    }
}
