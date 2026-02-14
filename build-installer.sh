#!/bin/bash

# Wake on LAN Installer Package Builder
# Builds a .pkg installer for Apple Silicon (arm64)

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="WakeOnLAN"
BUILD_DIR="$PROJECT_DIR/build"
PKG_ROOT="$PROJECT_DIR/pkg_root"
PKG_SCRIPTS="$PROJECT_DIR/pkg_scripts"
IDENTIFIER="com.wakeonlan.app"
VERSION="1.0"

echo "🔨 Building $PROJECT_NAME for Apple Silicon..."
echo ""

# Clean previous builds
if [ -d "$BUILD_DIR" ]; then
    echo "🧹 Cleaning previous build..."
    rm -rf "$BUILD_DIR"
fi

if [ -d "$PKG_ROOT" ]; then
    rm -rf "$PKG_ROOT"
fi

if [ -d "$PKG_SCRIPTS" ]; then
    rm -rf "$PKG_SCRIPTS"
fi

# Build the app for Apple Silicon only
echo "📦 Compiling application for arm64..."
xcodebuild -project "$PROJECT_DIR/$PROJECT_NAME.xcodeproj" \
    -scheme "$PROJECT_NAME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    -arch arm64 \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGN_STYLE=Manual \
    DEVELOPMENT_TEAM="" \
    ENABLE_HARDENED_RUNTIME=NO \
    build

# Find the built app
APP_PATH="$BUILD_DIR/Build/Products/Release/$PROJECT_NAME.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Build failed! App not found at expected location."
    exit 1
fi

echo "✅ Build successful!"
echo ""

# Create package root directory
echo "📁 Creating package structure..."
mkdir -p "$PKG_ROOT/Applications"
cp -R "$APP_PATH" "$PKG_ROOT/Applications/"

# Create scripts directory
mkdir -p "$PKG_SCRIPTS"

# Create postinstall script
cat > "$PKG_SCRIPTS/postinstall" << 'EOF'
#!/bin/bash

# Set proper permissions
chmod -R 755 /Applications/WakeOnLAN.app

# Remove quarantine attribute if present
xattr -dr com.apple.quarantine /Applications/WakeOnLAN.app 2>/dev/null || true

echo "Wake on LAN has been installed successfully!"
echo "You can launch it from your Applications folder."
echo "The app will appear in your menu bar (top-right corner)."

exit 0
EOF

chmod +x "$PKG_SCRIPTS/postinstall"

# Build the package
echo "📦 Building installer package..."
PKG_OUTPUT="$PROJECT_DIR/$PROJECT_NAME-AppleSilicon-v${VERSION}.pkg"

pkgbuild --root "$PKG_ROOT" \
    --identifier "$IDENTIFIER" \
    --version "$VERSION" \
    --install-location "/" \
    --scripts "$PKG_SCRIPTS" \
    "$PKG_OUTPUT"

# Clean up temporary directories
echo "🧹 Cleaning up..."
rm -rf "$PKG_ROOT"
rm -rf "$PKG_SCRIPTS"

echo ""
echo "✅ Installer package created successfully!"
echo "📍 Location: $PKG_OUTPUT"
echo ""
echo "Package details:"
ls -lh "$PKG_OUTPUT"
echo ""
echo "🎉 Installation instructions:"
echo "   1. Double-click the .pkg file"
echo "   2. Follow the installation wizard"
echo "   3. The app will appear in your menu bar (network icon)"
echo "   4. Click the icon to open the Wake on LAN manager"
echo ""
