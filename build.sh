#!/bin/bash

# Wake on LAN Build Script
# This script builds the macOS app and optionally creates a DMG for distribution

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="WakeOnLAN"
BUILD_DIR="$PROJECT_DIR/build"
RELEASE_DIR="$BUILD_DIR/Release"

echo "🔨 Building $PROJECT_NAME..."

# Clean previous builds
if [ -d "$BUILD_DIR" ]; then
    echo "🧹 Cleaning previous build..."
    rm -rf "$BUILD_DIR"
fi

# Build the app
echo "📦 Compiling application..."
xcodebuild -project "$PROJECT_DIR/$PROJECT_NAME.xcodeproj" \
    -scheme "$PROJECT_NAME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    build

# Find the built app
APP_PATH="$BUILD_DIR/Build/Products/Release/$PROJECT_NAME.app"

if [ -d "$APP_PATH" ]; then
    echo "✅ Build successful!"
    echo "📍 App location: $APP_PATH"
    
    # Optionally copy to Applications folder
    read -p "Do you want to copy the app to /Applications? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📥 Copying to /Applications..."
        cp -R "$APP_PATH" /Applications/
        echo "✅ Done! You can now run $PROJECT_NAME from your Applications folder."
    fi
    
    # Optionally open the app
    read -p "Do you want to open the app now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "$APP_PATH"
    fi
else
    echo "❌ Build failed! App not found at expected location."
    exit 1
fi

echo ""
echo "🎉 All done!"
