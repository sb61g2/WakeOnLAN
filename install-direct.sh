#!/bin/bash

# Wake on LAN - Direct Installation Script
# This script creates a runnable app bundle without requiring Xcode build

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="WakeOnLAN"
INSTALL_DIR="/Applications/$APP_NAME.app"

echo "🚀 Wake on LAN - Direct Installation"
echo "===================================="
echo ""

# Check if we have Swift compiler
if ! command -v swiftc &> /dev/null; then
    echo "❌ Swift compiler not found!"
    echo "Please install Xcode from the App Store, then run:"
    echo "  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    exit 1
fi

echo "📦 Creating app bundle structure..."

# Create app bundle structure
mkdir -p "$PROJECT_DIR/build/$APP_NAME.app/Contents/MacOS"
mkdir -p "$PROJECT_DIR/build/$APP_NAME.app/Contents/Resources"

# Copy Info.plist
echo "📋 Copying Info.plist..."
if [ -f "$PROJECT_DIR/Info-Standalone.plist" ]; then
    cp "$PROJECT_DIR/Info-Standalone.plist" "$PROJECT_DIR/build/$APP_NAME.app/Contents/Info.plist"
else
    # Fallback: create Info.plist on the fly
    cat > "$PROJECT_DIR/build/$APP_NAME.app/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>WakeOnLAN</string>
	<key>CFBundleIdentifier</key>
	<string>com.wakeonlan.app</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>Wake on LAN</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.utilities</string>
	<key>LSUIElement</key>
	<true/>
</dict>
</plist>
EOF
fi

# Copy Assets
echo "🎨 Copying assets..."
if [ -d "$PROJECT_DIR/Assets.xcassets" ]; then
    cp -R "$PROJECT_DIR/Assets.xcassets" "$PROJECT_DIR/build/$APP_NAME.app/Contents/Resources/"
fi

# Compile Swift files
echo "🔨 Compiling Swift code..."
echo "   This may take 10-20 seconds..."

# Ensure we have the SDK
SDK_PATH=$(xcrun --show-sdk-path 2>/dev/null)
if [ -z "$SDK_PATH" ]; then
    echo "❌ Cannot find macOS SDK!"
    echo "Please ensure Command Line Tools are installed:"
    echo "  xcode-select --install"
    exit 1
fi

echo "   Using SDK: $SDK_PATH"

# Compile all Swift files together
swiftc \
    -target arm64-apple-macos13.0 \
    -sdk "$SDK_PATH" \
    -O \
    -parse-as-library \
    "$PROJECT_DIR/WOLTarget.swift" \
    "$PROJECT_DIR/TargetManager.swift" \
    "$PROJECT_DIR/WOLSender.swift" \
    "$PROJECT_DIR/TargetEditorView.swift" \
    "$PROJECT_DIR/ContentView.swift" \
    "$PROJECT_DIR/WakeOnLANApp.swift" \
    -o "$PROJECT_DIR/build/$APP_NAME.app/Contents/MacOS/$APP_NAME"

COMPILE_STATUS=$?

if [ $COMPILE_STATUS -ne 0 ]; then
    echo ""
    echo "❌ Compilation failed!"
    echo ""
    echo "💡 Troubleshooting:"
    echo "   1. Make sure you're on Apple Silicon (arm64)"
    echo "   2. Verify macOS 13.0+ is installed"
    echo "   3. Try: xcode-select --install"
    echo ""
    exit 1
fi

# Verify the binary was created
if [ ! -f "$PROJECT_DIR/build/$APP_NAME.app/Contents/MacOS/$APP_NAME" ]; then
    echo "❌ Binary was not created!"
    echo "   Expected: $PROJECT_DIR/build/$APP_NAME.app/Contents/MacOS/$APP_NAME"
    exit 1
fi

echo "✅ Compilation successful!"

# Verify the binary
echo "🔍 Verifying binary..."
file "$PROJECT_DIR/build/$APP_NAME.app/Contents/MacOS/$APP_NAME"

echo ""

# Set permissions
echo "🔐 Setting permissions..."
chmod +x "$PROJECT_DIR/build/$APP_NAME.app/Contents/MacOS/$APP_NAME"

# Install
echo "📥 Installing to /Applications..."

if [ -d "$INSTALL_DIR" ]; then
    echo "⚠️  Existing installation found. Removing..."
    rm -rf "$INSTALL_DIR"
fi

cp -R "$PROJECT_DIR/build/$APP_NAME.app" "$INSTALL_DIR"

# Remove quarantine
xattr -dr com.apple.quarantine "$INSTALL_DIR" 2>/dev/null || true

# Verify installation
echo ""
echo "🔍 Verifying installation..."
if [ -f "$INSTALL_DIR/Contents/MacOS/$APP_NAME" ]; then
    echo "   ✓ Binary exists"
    ls -lh "$INSTALL_DIR/Contents/MacOS/$APP_NAME"
    
    if [ -x "$INSTALL_DIR/Contents/MacOS/$APP_NAME" ]; then
        echo "   ✓ Binary is executable"
    else
        echo "   ⚠ Binary is not executable, fixing..."
        chmod +x "$INSTALL_DIR/Contents/MacOS/$APP_NAME"
    fi
    
    echo "   ✓ Architecture:"
    file "$INSTALL_DIR/Contents/MacOS/$APP_NAME"
else
    echo "   ❌ Binary is missing!"
    exit 1
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "📍 Installed to: $INSTALL_DIR"
echo ""
echo "🎉 Wake on LAN is ready to use!"
echo ""
echo "To launch:"
echo "  1. Look for the network icon in your menu bar (top-right)"
echo "  2. If not visible, run: open /Applications/$APP_NAME.app"
echo ""
echo "To uninstall, run: sudo ./uninstall.sh"
echo ""

# Offer to launch
read -p "Would you like to launch the app now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$INSTALL_DIR"
    sleep 2
    echo ""
    echo "✅ App launched! Check your menu bar for the network icon."
fi

# Clean up build directory
rm -rf "$PROJECT_DIR/build"

echo ""
echo "🎉 All done!"
