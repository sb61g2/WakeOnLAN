# Release Notes

## Version 1.0 - Menu Bar Edition

**Release Date**: January 2026  
**Architecture**: Apple Silicon (arm64)  
**Minimum macOS**: 13.0 (Ventura)

### 🎉 Initial Release

This is the first public release of Wake on LAN for macOS, designed as a lightweight menu bar application for Apple Silicon Macs.

### ✨ Features

#### Core Functionality
- **Wake-on-LAN Magic Packets**: Send standard WOL packets to wake devices on your network
- **Target Management**: Save, edit, and delete target devices
- **Persistent Storage**: Targets are saved automatically and persist between app launches
- **Broadcast Calculation**: Automatically calculates broadcast address from IP and subnet mask

#### User Interface
- **Menu Bar Integration**: Runs as a menu bar app with no Dock icon
- **Popover Interface**: Clean, modern popover UI that appears when clicking the menu bar icon
- **Target List View**: Scrollable list of all saved wake targets
- **Empty State**: Helpful guidance when no targets are configured
- **Inline Actions**: Quick access to edit, delete, and wake functions for each target

#### Target Configuration
Each target stores:
- **Friendly Name**: Easy-to-remember device name
- **IP Address**: Device's network IP address
- **Subnet Mask**: Network subnet mask (defaults to 255.255.255.0)
- **MAC Address**: Hardware address of the device's network interface

#### Input Validation
- IP address format validation
- Subnet mask format validation
- MAC address format validation (supports both : and - separators)
- Required field checking

#### Network
- UDP broadcast on port 9
- Standard magic packet format (6×0xFF + 16×MAC)
- Automatic broadcast address calculation
- IPv4 support

### 🏗️ Technical Details

#### Architecture
- **Native SwiftUI** for modern, declarative UI
- **AppKit Integration** for menu bar functionality (NSStatusItem, NSPopover)
- **UserDefaults** for simple, reliable persistence
- **BSD Sockets** for low-level network packet sending

#### Requirements
- Apple Silicon Mac (M1, M2, M3, M4)
- macOS 13.0 (Ventura) or later
- Network access for sending UDP packets

#### Bundle Information
- **Bundle ID**: com.wakeonlan.app
- **Category**: Utilities
- **LSUIElement**: true (menu bar only, no Dock icon)

### 📦 Installation

The app is distributed as a standard macOS package (.pkg) installer:

1. Download `WakeOnLAN-AppleSilicon-v1.0.pkg`
2. Double-click to run the installer
3. Follow the installation wizard
4. The app installs to `/Applications/WakeOnLAN.app`
5. Look for the network icon in your menu bar

### 🔧 Usage

1. Click the network icon in your menu bar (top-right corner)
2. Click the [+] button to add a target
3. Enter device information (name, IP, subnet, MAC)
4. Click Save
5. Click the [Wake] button to send a magic packet

### 📝 Known Limitations

#### Current Version
- **IPv4 only**: No IPv6 support yet
- **Single port**: Fixed to port 9 (standard WOL port)
- **No scheduling**: Manual wake only (no scheduled or automated wake)
- **No status checking**: Cannot verify if device is awake
- **Local network**: Designed for same-network devices (no remote WOL)

#### Network Requirements
- Devices must support Wake-on-LAN
- WOL must be enabled in device BIOS/UEFI
- Devices should be on wired (Ethernet) connections
- Some routers may block broadcast packets

### 🐛 Bug Fixes

N/A - Initial release

### 🔮 Planned Features

Future releases may include:

- **Quick Wake Menu**: Right-click menu bar icon for instant wake shortcuts
- **Status Indicators**: Visual indication of device online/offline status
- **Scheduled Wake**: Automatic wake at specified times
- **Wake History**: Log of all sent magic packets
- **AppleScript Support**: Automation and integration capabilities
- **Keyboard Shortcuts**: Global hotkeys for quick wake
- **Import/Export**: Backup and restore target configurations
- **Groups**: Organize targets into categories
- **Port Selection**: Configure custom UDP ports
- **IPv6 Support**: Modern network protocol support

### 📄 Documentation

Included documentation:
- **README.md** - General information and getting started
- **QUICKSTART.md** - Quick setup guide
- **INSTALLER.md** - Building and distributing the installer
- **ARCHITECTURE.md** - Technical architecture details
- **INTERFACE.md** - Visual interface guide
- **build-installer.sh** - Automated installer build script
- **uninstall.sh** - Complete removal script

### 🙏 Acknowledgments

This app was created to provide a simple, lightweight, native macOS solution for Wake-on-LAN functionality, specifically optimized for Apple Silicon.

### 📞 Support

For issues, questions, or feature requests:
- Review the documentation files
- Check the troubleshooting section in README.md
- Verify network requirements in QUICKSTART.md

### ⚖️ License

This is a demonstration project provided as-is. Feel free to use and modify as needed.

---

**Architecture**: arm64 (Apple Silicon)  
**File Size**: ~200KB (app only), ~14KB (source archive)  
**Digital Signature**: Unsigned (suitable for personal use)
