import Foundation
import AppKit

/// ANSI color codes for terminal output
enum ANSIColor: String {
    case black = "\u{001B}[30m"
    case red = "\u{001B}[31m"
    case green = "\u{001B}[32m"
    case yellow = "\u{001B}[33m"
    case blue = "\u{001B}[34m"
    case magenta = "\u{001B}[35m"
    case cyan = "\u{001B}[36m"
    case white = "\u{001B}[37m"
    case reset = "\u{001B}[0m"
    case bold = "\u{001B}[1m"
}

/// UI utilities for terminal interface
struct UI {
    /// Print a colored message to the terminal
    static func printMessage(_ message: String, color: ANSIColor = .white) {
        print(color.rawValue + message + ANSIColor.reset.rawValue)
    }
    
    /// Print an error message in red
    static func printError(_ message: String) {
        printMessage("ERROR: \(message)", color: .red)
    }
    
    /// Print a success message in green
    static func printSuccess(_ message: String) {
        printMessage("SUCCESS: \(message)", color: .green)
    }
    
    /// Print a warning message in yellow
    static func printWarning(_ message: String) {
        printMessage("WARNING: \(message)", color: .yellow)
    }
    
    /// Print a header with emphasis
    static func printHeader(_ message: String) {
        print()
        printMessage("═══ \(message) ═══", color: .cyan)
        print()
    }
    
    /// Prompt user for yes/no confirmation
    static func promptYesNo(_ question: String, defaultYes: Bool = false) -> Bool {
        let defaultStr = defaultYes ? "[Y/n]" : "[y/N]"
        print("\(question) \(defaultStr): ", terminator: "")
        guard let response = readLine()?.lowercased() else {
            return defaultYes
        }
        
        if response.isEmpty {
            return defaultYes
        }
        return response == "y" || response == "yes"
    }
    
    /// Prompt user for a number within a range
    static func promptNumber(_ question: String, min: Int, max: Int) -> Int? {
        print("\(question) (\(min)–\(max)): ", terminator: "")
        guard let input = readLine(),
              let number = Int(input),
              number >= min && number <= max else {
            return nil
        }
        return number
    }
    
    /// Prompt user for exact string confirmation
    static func promptConfirmation(_ requiredString: String) -> Bool {
        printWarning("Type '\(requiredString)' to continue, or anything else to cancel.")
        print("> ", terminator: "")
        guard let input = readLine() else {
            return false
        }
        return input == requiredString
    }
    
    /// Display a progress bar
    static func showProgress(current: Int64, total: Int64, message: String = "Progress") {
        let percentage = min(Double(current) / Double(total) * 100.0, 99.9) // Cap at 99.9% until truly done
        let barLength = 40
        let filled = Int(percentage / 100.0 * Double(barLength))
        let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: barLength - filled)
        
        let currentMB = Double(current) / 1_000_000
        let totalMB = Double(total) / 1_000_000
        
        print("\r\(message): [\(bar)] \(String(format: "%.1f", percentage))% (\(String(format: "%.1f", currentMB))MB / \(String(format: "%.1f", totalMB))MB)", terminator: "")
        fflush(stdout)
    }
    
    /// Complete the progress bar and move to new line
    static func completeProgress() {
        print() // New line after progress is done
    }
    
    /// Open Finder dialog to select an ISO file
    static func selectISOFile() -> String? {
        let panel = NSOpenPanel()
        panel.title = "Select ISO File"
        panel.message = "Choose an ISO image to write to USB"
        panel.prompt = "Open"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.treatsFilePackagesAsDirectories = false
        panel.canCreateDirectories = false
        panel.showsHiddenFiles = false
        
        // Use allowedFileTypes for compatibility with macOS 10.15+
        if #available(macOS 11.0, *) {
            panel.allowedContentTypes = [.init(filenameExtension: "iso")!]
        } else {
            panel.allowedFileTypes = ["iso"]
        }
        
        // Set initial directory to Downloads
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        panel.directoryURL = downloadsURL
        
        // Don't try to activate - let the panel handle its own presentation
        // Run modal and block until user clicks Open or Cancel
        let response = panel.runModal()
        
        if response == .OK, let url = panel.url {
            return url.path
        }
        
        return nil
    }
}