import Foundation

/// Direct file-to-device writer (Rufus-style, no dd)
/// This is MUCH faster than calling dd
class DirectWriter {
    private let isoPath: String
    private let devicePath: String
    
    init(isoPath: String, devicePath: String) {
        self.isoPath = isoPath
        self.devicePath = devicePath
    }
    
    /// Write ISO directly to device with real progress
    func write() throws {
        // Get ISO size
        let attributes = try FileManager.default.attributesOfItem(atPath: isoPath)
        guard let fileSize = attributes[.size] as? Int64 else {
            throw NSError(domain: "DirectWriter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot get file size"])
        }
        
        UI.printMessage("ISO size: \(String(format: "%.2f", Double(fileSize) / 1_000_000)) MB", color: .cyan)
        print()
        
        // Open source (ISO file)
        guard let sourceFile = FileHandle(forReadingAtPath: isoPath) else {
            throw NSError(domain: "DirectWriter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot open ISO file"])
        }
        defer { try? sourceFile.close() }
        
        // Open destination (USB device) - requires sudo
        // We need to open the raw device with write permission
        let fileDescriptor = open(devicePath, O_WRONLY | O_SYNC)
        guard fileDescriptor >= 0 else {
            throw NSError(domain: "DirectWriter", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot open device (need sudo?)"])
        }
        defer { close(fileDescriptor) }
        
        UI.printSuccess("Opened \(devicePath) for writing")
        print()
        
        // Write buffer: 16MB for maximum speed
        let bufferSize = 16 * 1024 * 1024
        var totalWritten: Int64 = 0
        let startTime = Date()
        var lastUpdate = Date()
        
        UI.printMessage("Writing ISO to USB with 16MB buffers...", color: .cyan)
        print()
        
        while totalWritten < fileSize {
            autoreleasepool {
                // Read chunk from ISO
                let data = sourceFile.readData(ofLength: bufferSize)
                if data.isEmpty { return }
                
                // Write chunk to device
                let bytesToWrite = data.count
                let bytesWritten = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Int in
                    return Darwin.write(fileDescriptor, bytes.baseAddress!, bytesToWrite)
                }
                
                if bytesWritten < 0 {
                    // Write error
                    return
                }
                
                totalWritten += Int64(bytesWritten)
                
                // Update progress every second
                let now = Date()
                if now.timeIntervalSince(lastUpdate) >= 1.0 {
                    let percentage = Double(totalWritten) / Double(fileSize) * 100.0
                    let elapsed = now.timeIntervalSince(startTime)
                    let speed = Double(totalWritten) / elapsed / 1_000_000
                    let remaining = fileSize - totalWritten
                    let eta = remaining > 0 ? Double(remaining) / (speed * 1_000_000) : 0
                    
                    let etaMin = Int(eta / 60)
                    let etaSec = Int(eta.truncatingRemainder(dividingBy: 60))
                    
                    // Clear line and show progress
                    print("\r\u{001B}[K", terminator: "")
                    let barLength = 40
                    let filled = Int(percentage / 100.0 * Double(barLength))
                    let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: barLength - filled)
                    
                    print("[\(bar)] \(String(format: "%.1f", percentage))% | \(String(format: "%.1f", speed)) MB/s | ETA: \(etaMin)m \(etaSec)s  ", terminator: "")
                    fflush(stdout)
                    
                    lastUpdate = now
                }
            }
        }
        
        // Complete
        print()
        print()
        
        let totalTime = Date().timeIntervalSince(startTime)
        let avgSpeed = Double(fileSize) / totalTime / 1_000_000
        
        UI.printSuccess("Write complete in \(Int(totalTime / 60))m \(Int(totalTime.truncatingRemainder(dividingBy: 60)))s")
        UI.printMessage("Average speed: \(String(format: "%.1f", avgSpeed)) MB/s", color: .cyan)
        
        // Sync to ensure all data is flushed
        print()
        UI.printMessage("Syncing disk...", color: .cyan)
        fsync(fileDescriptor)
        
        UI.printSuccess("Sync complete!")
    }
}
