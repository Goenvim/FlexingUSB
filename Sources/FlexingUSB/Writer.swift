import Foundation
import CryptoKit

/// Thread-safe flag for controlling async operations
private class RunFlag {
    private var _value: Bool = true
    private let lock = NSLock()
    
    var value: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _value = newValue
        }
    }
}

/// Errors specific to writing operations
enum WriterError: Error, LocalizedError {
    case writeFailed(String)
    case verificationFailed
    case insufficientPrivileges
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .writeFailed(let message):
            return "Write failed: \(message)"
        case .verificationFailed:
            return "Verification failed: USB content doesn't match ISO"
        case .insufficientPrivileges:
            return "Insufficient privileges. Try running with sudo"
        case .cancelled:
            return "Operation cancelled by user"
        }
    }
}

/// Handles writing ISO images to USB drives and verification
class Writer {
    
    let isoPath: String
    let diskIdentifier: String
    let diskManager: DiskManager
    
    init(isoPath: String, diskIdentifier: String) {
        self.isoPath = isoPath
        self.diskIdentifier = diskIdentifier
        self.diskManager = DiskManager()
    }
    
    /// Write ISO to USB using dd command
    func writeWithDD(dryRun: Bool = false) throws {
        // Safety check
        try diskManager.verifySafeDisk(diskIdentifier)
        
        // Unmount the disk first
        UI.printMessage("Unmounting disk...", color: .cyan)
        try diskManager.unmountDisk(diskIdentifier)
        
        if dryRun {
            UI.printWarning("[DRY RUN] Would execute:")
            UI.printMessage("sudo dd if=\(isoPath) of=/dev/r\(diskIdentifier) bs=1m", color: .white)
            return
        }
        
        UI.printMessage("Writing ISO to USB using dd...", color: .cyan)
        UI.printWarning("This may take several minutes. Please be patient.")
        print()
        
        // Use rdisk for better performance
        let targetDevice = "/dev/r\(diskIdentifier)"
        
        // Check if we have root privileges
        let whoamiProcess = Process()
        whoamiProcess.executableURL = URL(fileURLWithPath: "/usr/bin/id")
        whoamiProcess.arguments = ["-u"]
        let whoamiPipe = Pipe()
        whoamiProcess.standardOutput = whoamiPipe
        try whoamiProcess.run()
        whoamiProcess.waitUntilExit()
        
        let uidData = whoamiPipe.fileHandleForReading.readDataToEndOfFile()
        let uidString = String(data: uidData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "1000"
        let needsSudo = uidString != "0"
        
        // Build the command
        let process = Process()
        if needsSudo {
            UI.printMessage("Note: You may be prompted for your password (sudo required)", color: .yellow)
            process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
            process.arguments = ["/bin/dd", "if=\(isoPath)", "of=\(targetDevice)", "bs=1m"]
        } else {
            process.executableURL = URL(fileURLWithPath: "/bin/dd")
            process.arguments = ["if=\(isoPath)", "of=\(targetDevice)", "bs=1m"]
        }
        
        let errorPipe = Pipe()
        process.standardError = errorPipe
        
        // Start the write process
        try process.run()
        
        // Monitor progress (dd doesn't provide easy progress, so we'll show a spinner)
        let startTime = Date()
        let isRunning = RunFlag()
        
        DispatchQueue.global().async {
            let spinner = ["|", "/", "-", "\\"]
            var index = 0
            while isRunning.value {
                print("\r\(spinner[index % spinner.count]) Writing... (elapsed: \(Int(Date().timeIntervalSince(startTime)))s)", terminator: "")
                fflush(stdout)
                index += 1
                Thread.sleep(forTimeInterval: 0.2)
            }
        }
        
        process.waitUntilExit()
        isRunning.value = false
        print() // New line after spinner
        
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw WriterError.writeFailed(errorMessage)
        }
        
        // Sync to ensure all data is written
        UI.printMessage("Syncing disk...", color: .cyan)
        try syncDisk()
        
        UI.printSuccess("Write complete!")
    }
    
    /// Write ISO to USB using asr (Apple Software Restore) - preferred method for macOS
    func writeWithASR(dryRun: Bool = false) throws {
        // Safety check
        try diskManager.verifySafeDisk(diskIdentifier)
        
        if dryRun {
            UI.printWarning("[DRY RUN] Would execute:")
            UI.printMessage("sudo asr restore --source \(isoPath) --target /dev/\(diskIdentifier) --erase --noprompt", color: .white)
            return
        }
        
        UI.printMessage("Writing ISO to USB using asr...", color: .cyan)
        UI.printWarning("This may take several minutes.")
        print()
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        process.arguments = [
            "/usr/sbin/asr",
            "restore",
            "--source", isoPath,
            "--target", "/dev/\(diskIdentifier)",
            "--erase",
            "--noprompt"
        ]
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe
        
        UI.printMessage("Note: You may be prompted for your password (sudo required)", color: .yellow)
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            
            // If asr fails, fall back to dd
            UI.printWarning("ASR failed, falling back to dd method...")
            UI.printMessage("Error was: \(errorMessage)", color: .yellow)
            try writeWithDD(dryRun: dryRun)
            return
        }
        
        let output = pipe.fileHandleForReading.readDataToEndOfFile()
        if let outputStr = String(data: output, encoding: .utf8), !outputStr.isEmpty {
            print(outputStr)
        }
        
        UI.printSuccess("Write complete!")
    }
    
    /// Sync disk to ensure all writes are flushed
    private func syncDisk() throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sync")
        try process.run()
        process.waitUntilExit()
        
        // Give the system a moment to finish
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    /// Verify the written USB matches the ISO
    func verify(isoChecksum: String? = nil) throws {
        UI.printHeader("Verifying written data")
        
        let isoManager = ISOManager(isoPath: isoPath)
        
        // Calculate ISO checksum if not provided
        let expectedChecksum: String
        if let checksum = isoChecksum {
            expectedChecksum = checksum
        } else {
            UI.printMessage("Calculating ISO checksum...", color: .cyan)
            expectedChecksum = try isoManager.calculateChecksum { current, total in
                UI.showProgress(current: current, total: total, message: "Hashing ISO")
            }
            UI.printMessage("ISO SHA256: \(expectedChecksum)", color: .white)
            print()
        }
        
        // Read from USB and calculate checksum
        UI.printMessage("Reading from USB to verify...", color: .cyan)
        let usbChecksum = try calculateUSBChecksum(bytes: try isoManager.getFileSize())
        UI.printMessage("USB SHA256: \(usbChecksum)", color: .white)
        print()
        
        // Compare
        if expectedChecksum == usbChecksum {
            UI.printSuccess("Verification passed! USB matches ISO perfectly.")
        } else {
            throw WriterError.verificationFailed
        }
    }
    
    /// Calculate checksum of data read from USB device
    private func calculateUSBChecksum(bytes: Int64) throws -> String {
        let devicePath = "/dev/r\(diskIdentifier)"
        let bufferSize = 1024 * 1024 * 10 // 10MB buffer
        
        let fileHandle = try FileHandle(forReadingFrom: URL(fileURLWithPath: devicePath))
        defer { try? fileHandle.close() }
        
        var hasher = SHA256()
        var totalRead: Int64 = 0
        
        while totalRead < bytes {
            let bytesToRead = min(bufferSize, Int(bytes - totalRead))
            let data = fileHandle.readData(ofLength: bytesToRead)
            
            if data.isEmpty { break }
            
            hasher.update(data: data)
            totalRead += Int64(data.count)
            
            UI.showProgress(current: totalRead, total: bytes, message: "Hashing USB")
        }
        
        print() // New line after progress
        
        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
