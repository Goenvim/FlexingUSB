# Security Policy

## Overview

FlexingUSB handles sensitive disk operations and requires administrator privileges. We take security seriously and have implemented multiple safety measures to protect your data.

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Safety Features

### 1. Internal Disk Protection

FlexingUSB **never** allows operations on `/dev/disk0` (your internal macOS drive):

```swift
// Automatic rejection of disk0
if diskIdentifier == "disk0" || diskIdentifier.hasPrefix("disk0s") {
    throw DiskError.internalDiskNotAllowed
}
```

### 2. External Disk Verification

All operations verify the target is an external disk:

```swift
// Only external disks are enumerated
diskutil list -plist external
```

### 3. Explicit Confirmation

Before any destructive operation, users must type "CONFIRM":

```bash
[WARNING]  Type 'CONFIRM' to continue, or anything else to cancel.
> CONFIRM
```

### 4. Dry Run Mode

Test operations without actual writes:

```bash
FlexingUSB start --dry-run
```

### 5. Privilege Requirements

- Sudo access required for disk writes
- User is prompted for password when needed
- No hardcoded credentials
- No privilege escalation exploits

## Security Best Practices

### For Users

1. **Always verify disk selection** before confirming
2. **Backup important data** before using FlexingUSB
3. **Use dry-run mode** when testing
4. **Download ISOs from official sources only**
5. **Verify ISO checksums** before writing
6. **Keep FlexingUSB updated** to latest version

### For Developers

1. **Never bypass safety checks**
2. **Test all changes with dry-run first**
3. **Review code for privilege escalation risks**
4. **Validate all user inputs**
5. **Use secure coding practices**
6. **Document security-related changes**

## Known Limitations

### 1. Sudo Requirement

FlexingUSB requires sudo for disk operations. This is by design and necessary for:
- Writing to raw disk devices
- Unmounting partitions
- Erasing disks

**Mitigation**: Only use official releases from trusted sources.

### 2. NSOpenPanel Security

The file picker has full file system access when running:
- Only `.iso` files are allowed
- No execution of selected files
- Read-only access to selected files

**Mitigation**: Review ISO selection carefully before proceeding.

### 3. Process Execution

FlexingUSB executes system commands:
- `diskutil` - Disk management
- `dd` - Disk writing
- `file` - File type detection
- `hdiutil` - Disk image operations

**Mitigation**: All commands use absolute paths and validated inputs.

## Reporting a Vulnerability

### What to Report

Please report any security issues including:

- Privilege escalation vulnerabilities
- Bypass of internal disk protection
- Input validation flaws
- Code injection vulnerabilities
- Denial of service issues
- Data leak possibilities

### How to Report

**DO NOT** open a public GitHub issue for security vulnerabilities.

Instead:

1. **Email**: Send details to `security@yourproject.com` (private)
2. **Include**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)
   - Your contact information

### What to Expect

- **24-48 hours**: Initial response acknowledging receipt
- **1 week**: Initial assessment and severity classification
- **2-4 weeks**: Fix development and testing
- **Coordinated disclosure**: We'll work with you on timing

### Recognition

Security researchers who responsibly disclose vulnerabilities will be:
- Credited in release notes (with permission)
- Listed in SECURITY.md (with permission)
- Thanked publicly (with permission)

## Security Update Policy

### Critical Vulnerabilities

- **Response time**: Within 24 hours
- **Fix release**: Within 7 days
- **User notification**: Immediate via GitHub releases

### High Severity

- **Response time**: Within 3 days
- **Fix release**: Within 14 days
- **User notification**: GitHub releases and README

### Medium/Low Severity

- **Response time**: Within 7 days
- **Fix release**: Next scheduled release
- **User notification**: Included in release notes

## Vulnerability Severity Classification

### Critical

- Allows operations on internal disk
- Privilege escalation without user consent
- Remote code execution
- Data destruction beyond user intent

### High

- Bypass of confirmation prompts
- Incorrect disk identification
- Memory corruption issues
- Information disclosure (sensitive data)

### Medium

- Input validation issues
- Denial of service (local)
- Error handling flaws
- Logging sensitive information

### Low

- Minor information disclosure
- UI/UX security improvements
- Documentation issues
- Non-exploitable bugs

## Security Auditing

### Code Review

All changes undergo security review:

```bash
# Pre-merge checklist
- [ ] Safety checks not bypassed
- [ ] No privilege escalation
- [ ] Input validation present
- [ ] Error handling secure
- [ ] No hardcoded credentials
- [ ] Logging doesn't expose secrets
```

### Testing

Security-focused test scenarios:

1. **Internal disk protection**:
   ```bash
   # Should always fail
   # Never allow disk0 operations
   ```

2. **Input validation**:
   ```bash
   # Test with malicious inputs
   # SQL injection patterns
   # Path traversal attempts
   ```

3. **Privilege escalation**:
   ```bash
   # Ensure sudo only when needed
   # No unnecessary privileges
   ```

## Dependencies

### ArgumentParser

- **Source**: Apple (official)
- **Version**: 1.2.0+
- **Risk**: Low (official Apple package)
- **Updates**: Monitor for security advisories

### System Tools

FlexingUSB relies on macOS system tools:

- `/usr/sbin/diskutil` - macOS system tool
- `/bin/dd` - Unix standard utility
- `/usr/bin/hdiutil` - macOS disk image tool
- `/usr/bin/file` - Unix file identification

**Security**: Using absolute paths prevents PATH hijacking.

## Secure Coding Guidelines

### Input Validation

```swift
// Always validate user input
guard let selection = UI.promptNumber("Select", min: 1, max: max) else {
    throw ValidationError.invalidInput
}
```

### Path Safety

```swift
// Use absolute paths for executables
process.executableURL = URL(fileURLWithPath: "/usr/sbin/diskutil")

// Never construct paths from user input without validation
```

### Error Handling

```swift
// Don't expose sensitive information in errors
catch {
    UI.printError("Operation failed")  // Generic message
    // Log details internally, not to user
}
```

## Incident Response

### In Case of Security Incident

1. **Immediate actions**:
   - Stop using affected version
   - Assess impact on your systems
   - Report to maintainers

2. **Investigation**:
   - Maintainers will investigate
   - Root cause analysis
   - Develop fix

3. **Resolution**:
   - Security patch released
   - Users notified
   - Post-mortem published

## Contact

- **Security Email**: security@yourproject.com (create this)
- **General Email**: contact@yourproject.com
- **GitHub Issues**: For non-security bugs only

## Legal

This project is provided "AS IS" without warranty. See [LICENSE](LICENSE) for details.

Users are responsible for:
- Verifying disk selection before confirmation
- Backing up important data
- Following security best practices
- Using software responsibly

---

**Last Updated**: October 23, 2024
**Version**: 1.0.0
