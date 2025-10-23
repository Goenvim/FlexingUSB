# Changelog

All notable changes to FlexingUSB will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-10-23

### Added
- Initial release of FlexingUSB
- Interactive `start` command for ISO-to-USB workflow
- `list` command to display all external USB drives
- `restore` command to format USB drives back to FAT32/exFAT
- `verify` command to check written ISO integrity
- Automatic ISO type detection (Windows, Linux, macOS)
- SHA256 checksum verification
- Safety features preventing operations on internal disk (/dev/disk0)
- Colorized terminal output with ANSI escape codes
- Progress indicators for long-running operations
- Native macOS file picker (NSOpenPanel) for ISO selection
- Dry-run mode for testing without writing
- Support for both dd and asr writing methods
- Comprehensive error handling and user confirmations
- Detailed documentation (README, CONTRIBUTING, LICENSE)

### Security
- Multiple safety checks to prevent accidental internal disk operations
- Explicit confirmation required before any destructive operation
- External disk verification before any write operation

## [Unreleased]

### Planned
- Unit tests for core functionality
- Homebrew formula for easy installation
- Better progress reporting for dd writes
- Actual Windows ISO patching implementation
- Benchmarking and performance metrics
- SwiftUI GUI mode
- Multi-USB write support (parallel operations)
