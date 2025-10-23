.PHONY: build release install clean test help

# Default target
all: build

# Build debug version
build:
	@echo "Building FlexingUSB (debug)..."
	swift build

# Build release version
release:
	@echo "Building FlexingUSB (release)..."
	swift build -c release

# Install to /usr/local/bin
install: release
	@echo "Installing FlexingUSB to /usr/local/bin..."
	@sudo cp .build/release/FlexingUSB /usr/local/bin/FlexingUSB
	@echo "✅ Installation complete! Run 'FlexingUSB --help' to get started."

# Uninstall from /usr/local/bin
uninstall:
	@echo "Uninstalling FlexingUSB..."
	@sudo rm -f /usr/local/bin/FlexingUSB
	@echo "✅ Uninstall complete."

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf .build
	@echo "✅ Clean complete."

# Run tests (when available)
test:
	@echo "Running tests..."
	swift test

# Run the debug binary
run:
	@echo "Running FlexingUSB..."
	swift run FlexingUSB

# Format code (requires swift-format)
format:
	@if command -v swift-format >/dev/null 2>&1; then \
		echo "Formatting code..."; \
		swift-format -i -r Sources/; \
		echo "✅ Format complete."; \
	else \
		echo "⚠️  swift-format not installed. Install with: brew install swift-format"; \
	fi

# Show help
help:
	@echo "FlexingUSB Makefile Targets:"
	@echo ""
	@echo "  make build       - Build debug version"
	@echo "  make release     - Build release version"
	@echo "  make install     - Install to /usr/local/bin (requires sudo)"
	@echo "  make uninstall   - Remove from /usr/local/bin (requires sudo)"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make test        - Run tests"
	@echo "  make run         - Run debug version"
	@echo "  make format      - Format source code (requires swift-format)"
	@echo "  make help        - Show this help message"
