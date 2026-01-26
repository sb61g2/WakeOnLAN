# Wake on LAN - macOS Menu Bar App

A lightweight native macOS menu bar application for sending Wake-on-LAN magic packets to network devices.

## Features

- 🎯 **Menu Bar Integration** - Lives in your macOS menu bar, always accessible
- 💾 Save and manage multiple WOL targets
- 📝 Store friendly names, IP addresses, subnet masks, and MAC addresses
- 🚀 One-click wake functionality
- ✏️ Edit and delete saved targets
- 💿 Persistent storage using UserDefaults
- 🍎 Native Apple Silicon support (arm64)
- 🎨 Clean, modern macOS interface using SwiftUI

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon Mac (M1, M2, M3, M4, etc.)
- Xcode 14.0 or later (for building from source)
- Swift 5.0 or later

## Building the App

### Quick Install (Command Line Tools Only):

If you only have Command Line Tools (not full Xcode):

```bash
./install-direct.sh
```

This compiles with `swiftc` and installs directly. See [INSTALL-NO-XCODE.md](INSTALL-NO-XCODE.md) for details.

### Using the Installer (Requires Full Xcode):

1. Build the installer package:
   ```bash
   ./build-installer.sh
   ```

2. Double-click the generated `.pkg` file

3. Follow the installation wizard

4. The app will appear in your menu bar with a network icon

### Using Xcode:

1. Open the project:
   ```bash
   open WakeOnLAN.xcodeproj
   ```

2. Select the "WakeOnLAN" scheme and your Mac as the destination

3. Build and run (⌘R) or build for archive (Product > Archive)

### Using Command Line:

Build the app from the terminal:

```bash
cd WakeOnLAN
xcodebuild -project WakeOnLAN.xcodeproj -scheme WakeOnLAN -configuration Release build
```

The built app will be located at:
```
build/Release/WakeOnLAN.app
```

## Usage

### Accessing the App

1. After installation, look for the network icon in your menu bar (top-right corner)
2. Click the icon to open the Wake on LAN popover
3. The app runs in the background - no Dock icon

### Adding a Target

1. Click the "+" button in the top-right corner
2. Enter the following information:
   - **Name**: Friendly name for the device (e.g., "My Desktop PC")
   - **IP Address**: The IP address of the target device (e.g., "192.168.1.100")
   - **Subnet Mask**: The subnet mask of your network (e.g., "255.255.255.0")
   - **MAC Address**: The MAC address of the target device (e.g., "AA:BB:CC:DD:EE:FF")
3. Click "Save"

### Waking a Device

Simply click the "Wake" button next to the target device. You'll see a confirmation alert when the magic packet is sent successfully.

### Editing a Target

Click the pencil icon next to any target to edit its information.

### Deleting a Target

Click the trash icon next to any target to remove it from your saved list.

## How Wake-on-LAN Works

Wake-on-LAN works by sending a special "magic packet" over the network to a device's network interface card (NIC). The magic packet contains:

1. 6 bytes of 0xFF (255)
2. The target MAC address repeated 16 times

The packet is sent as a UDP broadcast to the broadcast address calculated from the IP address and subnet mask.

## Network Requirements

For Wake-on-LAN to work:

1. **Target device must support WOL**: Check BIOS/UEFI settings
2. **WOL must be enabled**: Usually in BIOS/UEFI and sometimes in OS network settings
3. **Device must be connected to power**: Even when "off"
4. **Same network segment**: Device must be on the same local network or you need router configuration for remote WOL

## Technical Details

- **UDP Port**: 9 (standard WOL port)
- **Broadcast**: Uses calculated broadcast address based on IP and subnet mask
- **Storage**: Target information is stored in UserDefaults
- **Framework**: Built with SwiftUI for modern macOS interface

## App Structure

```
WakeOnLAN/
├── WakeOnLANApp.swift        # App entry point with menu bar setup
├── ContentView.swift          # Main UI with target list (menu bar popover)
├── TargetEditorView.swift     # Add/Edit target sheet
├── WOLTarget.swift            # Target data model
├── TargetManager.swift        # Persistence and state management
├── WOLSender.swift            # Magic packet creation and sending
└── Assets.xcassets/           # App icons and colors
```

## Uninstalling

To remove the app, run the uninstaller:

```bash
sudo ./uninstall.sh
```

Or manually:
1. Quit the app (click the X button in the menu bar popover)
2. Delete `/Applications/WakeOnLAN.app`
3. Optionally remove preferences: `~/Library/Preferences/com.wakeonlan.app.plist`

## App Structure

```
WakeOnLAN/
├── WakeOnLANApp.swift        # App entry point
├── ContentView.swift          # Main UI with target list
├── TargetEditorView.swift     # Add/Edit target sheet
├── WOLTarget.swift            # Target data model
├── TargetManager.swift        # Persistence and state management
├── WOLSender.swift            # Magic packet creation and sending
└── Assets.xcassets/           # App icons and colors
```

## Troubleshooting

### Magic packet sent but device doesn't wake:

1. Verify WOL is enabled in the device's BIOS/UEFI
2. Check network cable is connected (WiFi may not support WOL)
3. Ensure device is on the same network segment
4. Try the broadcast address 255.255.255.255 instead
5. Some NICs require specific driver settings in the OS

### Build errors:

- **"tool 'xcodebuild' requires Xcode"**: You only have Command Line Tools installed. Use `./install-direct.sh` instead, or install full Xcode from the App Store.
- Ensure you're running macOS 13.0 or later
- Verify you're on Apple Silicon (run `uname -m`, should show `arm64`)
- If using Xcode: Clean build folder (⌘⇧K) and rebuild

## License

This is a demonstration project. Feel free to use and modify as needed.

## Contributing

Suggestions and improvements are welcome!
