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
}
