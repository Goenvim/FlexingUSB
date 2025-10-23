# Contributing to FlexingUSB

Thank you for your interest in contributing to FlexingUSB! This document provides guidelines and instructions for contributing.

##  How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected vs actual behavior**
- **macOS version and Swift version**
- **FlexingUSB version**
- **Relevant logs or error messages**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description of the feature**
- **Explain why this enhancement would be useful**
- **Provide examples of how it would work**
- **Consider edge cases and potential issues**

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes**
4. **Test thoroughly**
5. **Commit with descriptive messages** (`git commit -m 'Add amazing feature'`)
6. **Push to your branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

##  Development Setup

### Prerequisites

- macOS 10.15 or later
- Xcode 15.0+ (for development)
- Swift 5.9+

### Building from Source

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/FlexingUSB.git
cd FlexingUSB

# Build the project
swift build

# Run during development
swift run FlexingUSB list

# Build release version
swift build -c release

# Run tests (when available)
swift test
```

### Project Structure

```
FlexingUSB/
├── Sources/FlexingUSB/
│   ├── main.swift         # CLI entry point and commands
│   ├── DiskManager.swift  # Disk operations and safety
│   ├── ISOManager.swift   # ISO handling and detection
│   ├── Writer.swift       # Writing and verification
│   └── UI.swift           # Terminal UI utilities
├── Tests/                 # Unit tests (to be added)
├── Package.swift          # SPM configuration
└── README.md              # Documentation
```

##  Code Style Guidelines

### Swift Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Keep functions focused and under 50 lines when possible
- Add documentation comments for public APIs

### Documentation

```swift
/// Brief description of what the function does
///
/// More detailed explanation if needed, including:
/// - Important behavior
/// - Edge cases
/// - Usage examples
///
/// - Parameters:
///   - param1: Description of parameter
///   - param2: Description of parameter
/// - Returns: Description of return value
/// - Throws: Description of errors that can be thrown
func exampleFunction(param1: String, param2: Int) throws -> Bool {
    // Implementation
}
```

### Error Handling

- Always use proper error handling with `throws` or `Result`
- Create descriptive error types
- Provide helpful error messages to users

```swift
enum MyError: Error, LocalizedError {
    case specificProblem(String)
    
    var errorDescription: String? {
        switch self {
        case .specificProblem(let details):
            return "Problem occurred: \(details)"
        }
    }
}
```

### Safety

- **Critical**: Never allow operations on internal disks
- Always validate user input
- Provide clear confirmations before destructive operations
- Include dry-run modes for testing

## 🧪 Testing

### Manual Testing Checklist

Before submitting a PR, test:

- [ ] `FlexingUSB list` - Lists external drives correctly
- [ ] `FlexingUSB start --dry-run` - Simulates without writing
- [ ] `FlexingUSB start` - Full write workflow
- [ ] `FlexingUSB restore` - USB restoration
- [ ] `FlexingUSB verify` - Verification process
- [ ] Error handling - Try invalid inputs
- [ ] Safety checks - Ensure disk0 is blocked

### Unit Tests (Future)

We're working on adding comprehensive unit tests. Areas that need testing:

- Disk parsing from `diskutil` output
- Safety validation logic
- ISO type detection
- Checksum calculation
- Error handling scenarios

##  UI/UX Guidelines

### Terminal Output

- Use colors meaningfully:
  - **Red**: Errors and critical warnings
  - **Yellow**: Warnings and cautions
  - **Green**: Success messages
  - **Cyan**: Headers and informational
  - **White**: Standard output

- Include emojis for better UX:
  - [OK] Success
  - [ERROR] Error
  - [WARNING] Warning
  -  Safety/Security

- Always show progress for long operations
- Provide clear, actionable error messages

### User Interactions

- Make prompts clear and unambiguous
- Provide sensible defaults
- Show what will happen before doing it
- Allow cancellation at any step

##  Code Review Process

### What We Look For

- **Correctness**: Does it work as intended?
- **Safety**: Does it maintain safety guarantees?
- **Code quality**: Is it readable and maintainable?
- **Documentation**: Are changes documented?
- **Testing**: Has it been tested thoroughly?
- **Performance**: Are there obvious performance issues?

### Review Timeline

- We aim to review PRs within 7 days
- Complex changes may take longer
- Please be patient and responsive to feedback

##  Areas for Contribution

### High Priority

- [ ] Unit tests for core functionality
- [ ] Homebrew formula for easy installation
- [ ] Better progress reporting during dd writes
- [ ] Benchmarking and performance metrics

### Medium Priority

- [ ] Full Windows ISO patching implementation
- [ ] Localization support
- [ ] Logging to file system
- [ ] Configuration file support
- [ ] Multiple USB write support (parallel)

### Nice to Have

- [ ] SwiftUI GUI mode
- [ ] Preset profiles for popular ISOs
- [ ] Disk cloning functionality
- [ ] Network ISO downloads
- [ ] Write speed optimization

##  Resources

### Learning Swift

- [Swift.org Documentation](https://swift.org/documentation/)
- [Swift Package Manager](https://swift.org/package-manager/)
- [Apple's Swift Guide](https://docs.swift.org/swift-book/)

### Related Technologies

- [ArgumentParser](https://github.com/apple/swift-argument-parser)
- [diskutil Manual](https://ss64.com/osx/diskutil.html)
- [dd Manual](https://ss64.com/osx/dd.html)

## 💬 Communication

### Where to Ask Questions

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and discussions
- **Pull Request comments**: Specific code questions

### Being Respectful

- Be kind and constructive
- Assume good intentions
- Focus on the code, not the person
- Help others learn and grow

## ⚖️ License

By contributing, you agree that your contributions will be licensed under the MIT License.

##  Recognition

Contributors will be recognized in:
- README.md acknowledgments
- Release notes
- GitHub contributors page

---

Thank you for contributing to FlexingUSB! 
