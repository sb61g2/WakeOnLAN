# Installation Troubleshooting Guide

## "The application cannot be opened because its executable is missing"

This error means the Swift compilation succeeded but the binary wasn't created or wasn't in the right location.

### Step 1: Run the Test Script

```bash
./test-compilation.sh
```

This will verify:
- Swift compiler is installed
- SDK is available
- Basic Swift compilation works
- SwiftUI compilation works

### Step 2: Check What Happened

Look at the build directory:

```bash
ls -la build/WakeOnLAN.app/Contents/MacOS/
```

If the file exists:
```bash
# Check if it's executable
file build/WakeOnLAN.app/Contents/MacOS/WakeOnLAN

# Make it executable
chmod +x build/WakeOnLAN.app/Contents/MacOS/WakeOnLAN
```

### Step 3: Try Manual Compilation

```bash
# Create directory
mkdir -p manual-build

# Compile
swiftc \
    -target arm64-apple-macos13.0 \
    -sdk "$(xcrun --show-sdk-path)" \
    -O \
    -parse-as-library \
    WOLTarget.swift \
    TargetManager.swift \
    WOLSender.swift \
    TargetEditorView.swift \
    ContentView.swift \
    WakeOnLANApp.swift \
    -o manual-build/WakeOnLAN

# Check result
ls -lh manual-build/WakeOnLAN
file manual-build/WakeOnLAN
```

If this creates a binary successfully, the issue is with the install script's paths.

### Step 4: Manual App Bundle Creation

If compilation works:

```bash
# Create app structure
mkdir -p ManualWOL.app/Contents/MacOS
mkdir -p ManualWOL.app/Contents/Resources

# Copy Info.plist
cp Info.plist ManualWOL.app/Contents/

# Copy the binary
cp manual-build/WakeOnLAN ManualWOL.app/Contents/MacOS/

# Make executable
chmod +x ManualWOL.app/Contents/MacOS/WakeOnLAN

# Copy to Applications
cp -R ManualWOL.app /Applications/WakeOnLAN.app

# Remove quarantine
xattr -dr com.apple.quarantine /Applications/WakeOnLAN.app

# Launch
open /Applications/WakeOnLAN.app
```

## Alternative: Install Full Xcode

If Command Line Tools aren't working properly:

1. **Open App Store**
2. **Search "Xcode"** and install (free, ~15GB)
3. **Open Xcode** once to install additional components
4. **Accept license**: `sudo xcodebuild -license accept`
5. **Switch to Xcode**:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   ```
6. **Use the Xcode build script**:
   ```bash
   ./build-installer.sh
   open WakeOnLAN-AppleSilicon-v1.0.pkg
   ```

## Common Issues

### "SDK not found"

```bash
# Install Command Line Tools
xcode-select --install

# Or if you have Xcode
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### "Target arm64 not supported"

Make sure you're on Apple Silicon:
```bash
uname -m
# Should output: arm64
```

If it says `x86_64`, you're on Intel and need to change the target:
```bash
# Edit install-direct.sh and change:
# -target arm64-apple-macos13.0
# to:
# -target x86_64-apple-macos13.0
```

### "Command Line Tools not installed"

```bash
xcode-select --install
```

Follow the prompts to install.

### "Parse error" or "Syntax error"

The Swift files may be corrupted. Re-extract the archive:
```bash
cd ..
rm -rf WakeOnLAN
tar -xzf WakeOnLAN-Fixed.tar.gz
cd WakeOnLAN
```

## Getting Help

If none of these work, gather this information:

```bash
# System info
sw_vers
uname -m

# Swift info
swiftc --version
xcode-select -p

# SDK info
xcrun --show-sdk-path

# Try compilation test
./test-compilation.sh
```

Then you'll have good diagnostic information to troubleshoot further.

## Nuclear Option: Use Xcode GUI

1. Install Xcode from App Store
2. Open `WakeOnLAN.xcodeproj` in Xcode
3. Select your Mac as the destination
4. Press ⌘R to build and run
5. Once running, right-click the app in Finder → Show in Finder
6. Copy `WakeOnLAN.app` to `/Applications`

This bypasses all command-line issues and uses Xcode's full build system.
