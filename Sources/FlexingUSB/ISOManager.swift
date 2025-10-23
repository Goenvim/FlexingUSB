import Foundation
import CryptoKit

/// Represents the type of ISO detected
enum ISOType: String {
    case windows = "Windows"
    case linux = "Linux"
    case macOS = "macOS"
    case unknown = "Unknown"
}

/// Errors specific to ISO operations
enum ISOError: Error, LocalizedError {
    case fileNotFound
    case invalidISO
    case mountFailed
    case patchingFailed
    case checksumFailed
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "ISO file not found"
        case .invalidISO:
            return "Invalid or corrupted ISO file"
        case .mountFailed:
            return "Failed to mount ISO"
        case .patchingFailed:
            return "Failed to patch Windows ISO"
        case .checksumFailed:
            return "Checksum verification failed"
        }
    }
}

/// Manages ISO file operations including detection, patching, and verification
class ISOManager {
    
    let isoPath: String
    
    init(isoPath: String) {
        self.isoPath = isoPath
    }
    
    /// Verify that the ISO file exists and is readable
    func verifyExists() throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: isoPath) else {
            throw ISOError.fileNotFound
        }
        guard fileManager.isReadableFile(atPath: isoPath) else {
            throw ISOError.invalidISO
        }
    }
    
    /// Get the size of the ISO file
    func getFileSize() throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: isoPath)
        return attributes[.size] as? Int64 ?? 0
    }
    
    /// Detect the type of ISO using file command and pattern matching
    func detectType() -> ISOType {
        do {
            // Try using 'file' command first
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/file")
            process.arguments = ["-b", isoPath]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.lowercased() {
                // Check for Windows patterns
                if output.contains("microsoft") || output.contains("windows") {
                    return detectWindowsVersion()
                }
                // Check for Linux patterns
                if output.contains("linux") || output.contains("ubuntu") || 
                   output.contains("fedora") || output.contains("debian") {
                    return .linux
                }
                // Check for macOS patterns
                if output.contains("macos") || output.contains("mac os") {
                    return .macOS
                }
            }
            
            // Fallback: try to read volume label using hdiutil
            return detectTypeUsingHdiutil()
            
        } catch {
            UI.printWarning("Failed to detect ISO type: \(error.localizedDescription)")
            return .unknown
        }
    }
    
    /// Detect Windows version by examining ISO contents
    private func detectWindowsVersion() -> ISOType {
        // For now, just return Windows - could be enhanced to detect Win10 vs Win11
        return .windows
    }
    
    /// Alternative detection method using hdiutil
    private func detectTypeUsingHdiutil() -> ISOType {
        do {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
            process.arguments = ["imageinfo", isoPath]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.lowercased() {
                if output.contains("windows") || output.contains("microsoft") {
                    return .windows
                }
                if output.contains("linux") || output.contains("ubuntu") {
                    return .linux
                }
                if output.contains("macos") || output.contains("mac os x") {
                    return .macOS
                }
            }
        } catch {
            // Silent failure - return unknown
        }
        return .unknown
    }
    
    /// Get human-readable description of the ISO
    func getDescription() -> String {
        let type = detectType()
        
        switch type {
        case .windows:
            return "Windows installation image"
        case .linux:
            return "Linux distribution image"
        case .macOS:
            return "macOS installer image"
        case .unknown:
            return "Unknown ISO type"
        }
    }
    
    /// Calculate SHA256 checksum of the ISO file
    func calculateChecksum(progressCallback: ((Int64, Int64) -> Void)? = nil) throws -> String {
        let bufferSize = 1024 * 1024 * 10 // 10MB buffer
        let fileHandle = try FileHandle(forReadingFrom: URL(fileURLWithPath: isoPath))
        defer { try? fileHandle.close() }
        
        var hasher = SHA256()
        var totalRead: Int64 = 0
        let fileSize = try getFileSize()
        
        while autoreleasepool(invoking: {
            let data = fileHandle.readData(ofLength: bufferSize)
            if data.isEmpty { return false }
            hasher.update(data: data)
            totalRead += Int64(data.count)
            progressCallback?(totalRead, fileSize)
            return true
        }) {}
        
        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    /// Patch Windows ISO to remove TPM/Secure Boot requirements (placeholder)
    /// Note: This is a simplified version. Full implementation would require
    /// mounting the ISO, modifying registry/WIM files, and rebuilding.
    func patchWindowsISO() throws -> String {
        UI.printWarning("Windows ISO patching is experimental.")
        UI.printMessage("This would typically involve:", color: .yellow)
        UI.printMessage("  1. Mounting the ISO", color: .white)
        UI.printMessage("  2. Copying contents to temp directory", color: .white)
        UI.printMessage("  3. Modifying install.wim or boot.wim", color: .white)
        UI.printMessage("  4. Rebuilding the ISO", color: .white)
        print()
        
        // For safety and complexity reasons, we'll skip actual patching
        // Users can use tools like Rufus on Windows or manual methods
        UI.printMessage("For now, we'll use the original ISO.", color: .cyan)
        UI.printMessage("To bypass TPM requirements on Windows 11, you can:", color: .white)
        UI.printMessage("  - Use Rufus on Windows with TPM bypass option", color: .white)
        UI.printMessage("  - Press Shift+F10 during install and modify registry", color: .white)
        print()
        
        return isoPath // Return original ISO path
    }
}
