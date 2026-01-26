# Building the Installer Package

This guide explains how to build the Wake on LAN installer package for Apple Silicon Macs.

## Prerequisites

- Mac with Apple Silicon (M1, M2, M3, M4, etc.)
- macOS 13.0 (Ventura) or later
- Xcode 14.0 or later installed
- Command Line Tools installed

## Quick Build

Simply run the build script:

```bash
cd WakeOnLAN
./build-installer.sh
```

This will:
1. Build the app for arm64 architecture
2. Create a package structure
3. Generate a `.pkg` installer file
4. Output: `WakeOnLAN-AppleSilicon-v1.0.pkg`

## Installation

### For End Users

1. Double-click `WakeOnLAN-AppleSilicon-v1.0.pkg`
2. Follow the installation wizard
3. Click "Install"
4. Enter your password when prompted
5. The app will be installed to `/Applications/WakeOnLAN.app`
6. Look for the network icon in your menu bar

### First Launch

- The app automatically launches as a menu bar app
- Click the network icon in the top-right corner
- No Dock icon appears (this is intentional)

## Manual Build Steps

If you prefer to build manually:

### 1. Build the App

```bash
xcodebuild -project WakeOnLAN.xcodeproj \
    -scheme WakeOnLAN \
    -configuration Release \
    -arch arm64 \
    build
```

### 2. Create Package Root

```bash
mkdir -p pkg_root/Applications
cp -R build/Build/Products/Release/WakeOnLAN.app pkg_root/Applications/
```

### 3. Create Post-Install Script

Create `pkg_scripts/postinstall`:

```bash
#!/bin/bash
chmod -R 755 /Applications/WakeOnLAN.app
xattr -dr com.apple.quarantine /Applications/WakeOnLAN.app 2>/dev/null || true
exit 0
```

Make it executable:
```bash
chmod +x pkg_scripts/postinstall
```

### 4. Build Package

```bash
pkgbuild --root pkg_root \
    --identifier com.wakeonlan.app \
    --version 1.0 \
    --install-location / \
    --scripts pkg_scripts \
    WakeOnLAN-AppleSilicon-v1.0.pkg
```

## Verification

After installation, verify:

```bash
# Check if app exists
ls -la /Applications/WakeOnLAN.app

# Check architecture
file /Applications/WakeOnLAN.app/Contents/MacOS/WakeOnLAN
# Should show: Mach-O 64-bit executable arm64

# Check if it's a menu bar app
defaults read /Applications/WakeOnLAN.app/Contents/Info.plist LSUIElement
# Should output: 1
```

## Distribution

To distribute the installer:

1. Compress the .pkg file:
   ```bash
   zip WakeOnLAN-AppleSilicon-v1.0.zip WakeOnLAN-AppleSilicon-v1.0.pkg
   ```

2. Or create a DMG (optional):
   ```bash
   hdiutil create -volname "Wake on LAN" \
       -srcfolder WakeOnLAN-AppleSilicon-v1.0.pkg \
       -ov -format UDZO \
       WakeOnLAN-Installer.dmg
   ```

## Code Signing (Optional)

For distribution outside your organization, you should sign the package:

### Sign the App

```bash
codesign --force --deep --sign "Developer ID Application: Your Name" \
    /Applications/WakeOnLAN.app
```

### Sign the Installer

```bash
productsign --sign "Developer ID Installer: Your Name" \
    WakeOnLAN-AppleSilicon-v1.0.pkg \
    WakeOnLAN-AppleSilicon-v1.0-signed.pkg
```

### Notarize (for Gatekeeper)

```bash
xcrun notarytool submit WakeOnLAN-AppleSilicon-v1.0-signed.pkg \
    --apple-id "your@email.com" \
    --team-id "TEAMID" \
    --password "app-specific-password" \
    --wait
```

## Troubleshooting

### "App is damaged and can't be opened"

Remove quarantine attribute:
```bash
sudo xattr -rd com.apple.quarantine /Applications/WakeOnLAN.app
```

### App won't launch

Check permissions:
```bash
sudo chmod -R 755 /Applications/WakeOnLAN.app
```

### Can't find the app

Menu bar apps don't appear in the Dock. Look for the network icon in the menu bar (top-right corner).

### Build fails

- Ensure Xcode Command Line Tools are installed:
  ```bash
  xcode-select --install
  ```
- Check Xcode is the active developer directory:
  ```bash
  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
  ```

## Uninstallation

Use the provided uninstaller:
```bash
sudo ./uninstall.sh
```

Or manually:
1. Delete the app: `sudo rm -rf /Applications/WakeOnLAN.app`
2. Remove preferences: `rm ~/Library/Preferences/com.wakeonlan.app.plist`

## Package Details

- **Format**: Flat package (.pkg)
- **Architecture**: arm64 (Apple Silicon)
- **Install Location**: /Applications
- **Identifier**: com.wakeonlan.app
- **Version**: 1.0
- **Minimum macOS**: 13.0 (Ventura)

## Support

For issues or questions, refer to:
- README.md - General documentation
- QUICKSTART.md - Quick start guide
- ARCHITECTURE.md - Technical details
