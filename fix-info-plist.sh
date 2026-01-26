#!/bin/bash

# Fix Info.plist for installed app
# This fixes the $(EXECUTABLE_NAME) variable issue

echo "🔧 Fixing Info.plist..."
echo ""

APP_PATH="/Applications/WakeOnLAN.app"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ App not found at $APP_PATH"
    exit 1
fi

# Backup old Info.plist
cp "$APP_PATH/Contents/Info.plist" "$APP_PATH/Contents/Info.plist.bak"

# Create corrected Info.plist
cat > "$APP_PATH/Contents/Info.plist" << 'EOF'
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

echo "✅ Info.plist fixed!"
echo ""
echo "Old Info.plist backed up to: Info.plist.bak"
echo ""
echo "Now try launching:"
echo "  open /Applications/WakeOnLAN.app"
echo ""
