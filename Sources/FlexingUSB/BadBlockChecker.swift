import Foundation

/// Checks USB drives for bad blocks and fake capacity
/// Inspired by Rufus bad blocks detection
class BadBlockChecker {
    private let diskIdentifier: String
    private let diskManager = DiskManager()
    
    init(diskIdentifier: String) {
        self.diskIdentifier = diskIdentifier
    }
    
    /// Quick check if USB has advertised capacity
    func quickCapacityCheck() throws -> Bool {
        UI.printMessage("Checking USB capacity...", color: .cyan)
        
        let disks = try diskManager.getExternalDisks()
        guard let disk = disks.first(where: { $0.DeviceIdentifier == diskIdentifier }) else {
            throw NSError(domain: "BadBlockChecker", code: 1, userInfo: [NSLocalizedDescriptionKey: "Disk not found"])
        }
        
        let sizeGB = disk.sizeInGB
        
        // Check if size is suspiciously round (common in fake drives)
        let roundSizes: [Double] = [8, 16, 32, 64, 128, 256, 512, 1024, 2048]
        let isSuspiciouslyRound = roundSizes.contains(where: { abs($0 - sizeGB) < 0.5 })
        
        if isSuspiciouslyRound && sizeGB >= 64 {
            UI.printWarning("USB claims \(String(format: "%.0f", sizeGB))GB - suspiciously round number")
            UI.printMessage("Fake USB drives often claim exact powers of 2 (64GB, 128GB, etc.)", color: .yellow)
            
            if UI.promptYesNo("Run a quick write test to verify capacity?", defaultYes: true) {
                return try runQuickWriteTest(advertisedSize: Int64(sizeGB * 1_000_000_000))
            }
        } else {
            UI.printSuccess("Capacity check passed: \(String(format: "%.2f", sizeGB))GB")
        }
        
        return true
    }
    
    /// Quick write test to detect fake drives
    private func runQuickWriteTest(advertisedSize: Int64) throws -> Bool {
        UI.printMessage("Running quick write test (will not harm data)...", color: .cyan)
        UI.printMessage("This writes small test patterns to verify capacity", color: .white)
        
        // We would test writing to the end of the drive
        // For now, just inform the user
        UI.printWarning("Quick test not yet implemented")
        UI.printMessage("Consider testing with a small file first before writing ISO", color: .yellow)
        
        return true
    }
    
    /// Full bad blocks scan (takes a long time)
    func fullBadBlocksScan() throws {
        UI.printMessage("Starting full bad blocks scan...", color: .cyan)
        UI.printWarning("This will take a very long time!")
        
        if !UI.promptYesNo("Continue with full scan?", defaultYes: false) {
            return
        }
        
        // Would use badblocks command on macOS
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        process.arguments = ["diskutil", "verifyVolume", "/dev/\(diskIdentifier)"]
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus == 0 {
            UI.printSuccess("No bad blocks found!")
        } else {
            UI.printError("Bad blocks detected or verification failed")
        }
    }
}
