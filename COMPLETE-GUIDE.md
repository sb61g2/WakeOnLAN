# Complete Build & Installation Guide

This document provides everything you need to build, install, and use the Wake on LAN menu bar app on your Apple Silicon Mac.

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Building the Installer](#building-the-installer)
4. [Installing the App](#installing-the-app)
5. [First Time Use](#first-time-use)
6. [Troubleshooting](#troubleshooting)
7. [Uninstalling](#uninstalling)

---

## Quick Start

**For M4 Mac mini users:**

```bash
# 1. Extract the archive
tar -xzf WakeOnLAN-MenuBar.tar.gz
cd WakeOnLAN

# 2. Build the installer
./build-installer.sh

# 3. Install the package
open WakeOnLAN-AppleSilicon-v1.0.pkg

# 4. Look for the network icon in your menu bar!
```

---

## Prerequisites

### System Requirements
- **Mac**: Apple Silicon (M1/M2/M3/M4)
- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 14.0 or later
- **Command Line Tools**: Installed

### Verify Your System

Check your architecture:
```bash
uname -m
# Should output: arm64
```

Check macOS version:
```bash
sw_vers
# ProductVersion should be 13.0 or higher
```

Check if Xcode is installed:
```bash
xcode-select -p
# Should show: /Applications/Xcode.app/Contents/Developer
```

If Xcode Command Line Tools aren't installed:
```bash
xcode-select --install
```

---

## Building the Installer

### Automated Build (Recommended)

The included script handles everything:

```bash
cd WakeOnLAN
./build-installer.sh
```

**What it does:**
1. Cleans any previous builds
2. Compiles the app for arm64
3. Creates package directory structure
4. Generates post-install script
5. Builds the .pkg installer
6. Cleans up temporary files

**Output:**
- `WakeOnLAN-AppleSilicon-v1.0.pkg` (in the project directory)

### Manual Build (Advanced)

If you prefer manual control:

```bash
# 1. Build the app
xcodebuild -project WakeOnLAN.xcodeproj \
    -scheme WakeOnLAN \
    -configuration Release \
    -arch arm64 \
    build

# 2. Create package structure
mkdir -p pkg_root/Applications
cp -R build/Build/Products/Release/WakeOnLAN.app \
    pkg_root/Applications/

# 3. Create post-install script
mkdir -p pkg_scripts
cat > pkg_scripts/postinstall << 'EOF'
#!/bin/bash
chmod -R 755 /Applications/WakeOnLAN.app
xattr -dr com.apple.quarantine /Applications/WakeOnLAN.app 2>/dev/null || true
exit 0
EOF
chmod +x pkg_scripts/postinstall

# 4. Build package
pkgbuild --root pkg_root \
    --identifier com.wakeonlan.app \
    --version 1.0 \
    --install-location / \
    --scripts pkg_scripts \
    WakeOnLAN-AppleSilicon-v1.0.pkg

# 5. Clean up
rm -rf pkg_root pkg_scripts
```

---

## Installing the App

### Using the Installer Package

1. **Locate the package:**
   ```bash
   ls -lh WakeOnLAN-AppleSilicon-v1.0.pkg
   ```

2. **Double-click** the .pkg file, or use terminal:
   ```bash
   open WakeOnLAN-AppleSilicon-v1.0.pkg
   ```

3. **Follow the installer wizard:**
   - Click "Continue"
   - Review the information
   - Click "Install"
   - Enter your password when prompted
   - Click "Close" when complete

4. **Verify installation:**
   ```bash
   ls -la /Applications/WakeOnLAN.app
   ```

### Direct Installation (No Installer)

If you just want to run the app without the installer:

```bash
# Build and copy directly
xcodebuild -project WakeOnLAN.xcodeproj \
    -scheme WakeOnLAN \
    -configuration Release \
    -arch arm64 \
    build

cp -R build/Build/Products/Release/WakeOnLAN.app \
    /Applications/

# Remove quarantine
xattr -dr com.apple.quarantine /Applications/WakeOnLAN.app
```

---

## First Time Use

### Launching the App

The app **does not appear in the Dock**. This is intentional - it's a menu bar app.

1. **Look in your menu bar** (top-right corner of screen)
2. **Find the network icon** (📶)
3. **Click the icon** to open the popover

If you don't see the icon, manually launch:
```bash
open /Applications/WakeOnLAN.app
```

### Adding Your First Target

1. **Click the menu bar icon**
2. **Click the [+] button** in the popover
3. **Enter device information:**

   Example for a typical PC:
   ```
   Name:         Living Room PC
   IP Address:   192.168.1.100
   Subnet Mask:  255.255.255.0
   MAC Address:  AA:BB:CC:DD:EE:FF
   ```

4. **Click Save**

### Finding Your Device's MAC Address

**On the target device:**

Windows:
```cmd
ipconfig /all
```
Look for "Physical Address"

Linux:
```bash
ip link show
# or
ifconfig
```

macOS:
```bash
ifconfig en0 | grep ether
```

**On your router:**
- Check DHCP client list
- Look for connected devices
- Note the MAC address

### Sending Your First Magic Packet

1. **Click the [Wake] button** next to your target
2. **Alert appears** confirming packet sent
3. **Target device should wake** (if properly configured)

---

## Troubleshooting

### App Won't Launch

**"WakeOnLAN is damaged and can't be opened"**
```bash
sudo xattr -rd com.apple.quarantine /Applications/WakeOnLAN.app
```

**Permission issues:**
```bash
sudo chmod -R 755 /Applications/WakeOnLAN.app
```

**Check if running:**
```bash
ps aux | grep WakeOnLAN
```

### Can't Find Menu Bar Icon

1. **Check System Settings:**
   - System Settings → Control Center
   - Verify menu bar isn't too crowded

2. **Manually launch:**
   ```bash
   open /Applications/WakeOnLAN.app
   ```

3. **Check Console for errors:**
   ```bash
   log show --predicate 'process == "WakeOnLAN"' --last 5m
   ```

### Device Won't Wake

**Enable WOL in BIOS/UEFI:**
1. Restart target device
2. Enter BIOS (usually Del, F2, or F12)
3. Find "Wake on LAN" setting
4. Enable it
5. Save and exit

**Check network settings (Windows):**
1. Device Manager
2. Network adapters
3. Right-click adapter → Properties
4. Advanced tab → Enable "Wake on Magic Packet"
5. Power Management tab → Check "Allow this device to wake the computer"

**Verify MAC address is correct:**
```bash
# On target device (Windows)
ipconfig /all
```

**Test from command line:**
```bash
# Install wakeonlan utility
brew install wakeonlan

# Test sending packet
wakeonlan AA:BB:CC:DD:EE:FF
```

### Build Fails

**Xcode not found:**
```bash
xcode-select --install
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

**Wrong architecture:**
```bash
# Verify you're building for arm64
file /Applications/WakeOnLAN.app/Contents/MacOS/WakeOnLAN
# Should show: Mach-O 64-bit executable arm64
```

**Clean and rebuild:**
```bash
rm -rf build
./build-installer.sh
```

---

## Uninstalling

### Using the Uninstaller Script

```bash
cd WakeOnLAN
sudo ./uninstall.sh
```

This will:
1. Remove the app from Applications
2. Optionally remove saved preferences
3. Clean up all app data

### Manual Uninstall

```bash
# Remove app
sudo rm -rf /Applications/WakeOnLAN.app

# Remove preferences (optional)
rm ~/Library/Preferences/com.wakeonlan.app.plist

# Verify removal
ls /Applications/WakeOnLAN.app
# Should return: No such file or directory
```

---

## Advanced Configuration

### Running at Login

To start automatically:

1. **System Settings**
2. **General → Login Items**
3. Click **+** button
4. Navigate to `/Applications/WakeOnLAN.app`
5. Click **Add**

Or via command line:
```bash
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/WakeOnLAN.app", hidden:false}'
```

### AppleScript Integration

While not built-in yet, you can trigger launch via AppleScript:

```applescript
tell application "WakeOnLAN"
    activate
end tell
```

### Command Line Usage

While the app doesn't have CLI yet, you can:

```bash
# Launch the app
open -a WakeOnLAN

# Send packet using system wakeonlan
brew install wakeonlan
wakeonlan AA:BB:CC:DD:EE:FF
```

---

## Additional Resources

- **README.md** - Overview and features
- **QUICKSTART.md** - Quick setup guide
- **INSTALLER.md** - Detailed installer documentation
- **ARCHITECTURE.md** - Technical architecture
- **INTERFACE.md** - UI/UX documentation
- **RELEASE-NOTES.md** - Version history

---

## Success Checklist

✅ Mac is Apple Silicon (M1/M2/M3/M4)  
✅ macOS 13.0+ installed  
✅ Xcode 14.0+ installed  
✅ Built the installer successfully  
✅ Installed via .pkg file  
✅ Can see network icon in menu bar  
✅ Added at least one target  
✅ Successfully sent magic packet  
✅ Target device woke up  

**Congratulations! You're all set!** 🎉

---

**Need help?** Review the troubleshooting section or check the individual documentation files.
