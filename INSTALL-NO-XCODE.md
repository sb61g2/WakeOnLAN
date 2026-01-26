# Installation Without Xcode

If you only have Command Line Tools installed (not full Xcode), use this guide.

## Quick Install

```bash
cd WakeOnLAN
./install-direct.sh
```

This script:
1. Uses `swiftc` (comes with Command Line Tools)
2. Compiles the Swift files directly
3. Creates the app bundle
4. Installs to /Applications
5. Removes quarantine attributes

## If You Get Errors

### "Swift compiler not found"

You need Command Line Tools:
```bash
xcode-select --install
```

### "SDK not found"

Point to the right developer directory:
```bash
sudo xcode-select --switch /Library/Developer/CommandLineTools
```

### "Target arm64 not supported"

Make sure you're on an Apple Silicon Mac:
```bash
uname -m
# Should output: arm64
```

If you're on Intel, you'll need to install full Xcode from the App Store.

## Alternative: Install Full Xcode

If direct compilation doesn't work:

1. **Open App Store**
2. **Search for "Xcode"**
3. **Click "Get" or "Install"** (it's free but large, ~15GB)
4. **Wait for installation** (may take 30-60 minutes)
5. **Open Xcode once** to accept license
6. **Set developer directory:**
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   ```
7. **Run the original installer:**
   ```bash
   ./build-installer.sh
   ```

## Comparison

| Method | Requirements | Time | Output |
|--------|-------------|------|--------|
| `install-direct.sh` | Command Line Tools | 5 seconds | Working app |
| `build-installer.sh` | Full Xcode | 30 seconds | .pkg installer |

## Verification

After installation, verify it worked:

```bash
# Check app exists
ls -la /Applications/WakeOnLAN.app

# Check binary architecture
file /Applications/WakeOnLAN.app/Contents/MacOS/WakeOnLAN
# Should show: Mach-O 64-bit executable arm64

# Launch it
open /Applications/WakeOnLAN.app
```

Look for the network icon in your menu bar!

## Troubleshooting

### "Permission denied"

Run with sudo for the install step:
```bash
sudo ./install-direct.sh
```

### "App is damaged"

Remove quarantine manually:
```bash
sudo xattr -rd com.apple.quarantine /Applications/WakeOnLAN.app
```

### Can't see menu bar icon

Launch manually:
```bash
open /Applications/WakeOnLAN.app
```

Check Activity Monitor to see if it's running:
```bash
ps aux | grep WakeOnLAN
```

### Compilation fails

Make sure all Swift files are present:
```bash
ls -la *.swift
```

Should see:
- WakeOnLANApp.swift
- ContentView.swift
- TargetEditorView.swift
- WOLTarget.swift
- TargetManager.swift
- WOLSender.swift

## Need the .pkg Installer?

If you want to distribute to other Macs, you'll need full Xcode to build the .pkg installer. The direct install only creates the app for your local machine.

## Success!

Once installed, you should see a network icon (📶) in your menu bar. Click it to start using Wake on LAN!
