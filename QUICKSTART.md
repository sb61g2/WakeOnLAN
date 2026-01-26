# Quick Start Guide - Wake on LAN Menu Bar App

## Installation

### Option 1: Direct Install (Easiest - No Xcode Required)

**Perfect if you only have Command Line Tools:**

1. **Extract and navigate:**
   ```bash
   tar -xzf WakeOnLAN-MenuBar-Installer.tar.gz
   cd WakeOnLAN
   ```

2. **Run the direct installer:**
   ```bash
   ./install-direct.sh
   ```

3. **Look for the network icon** in your menu bar (top-right corner)

4. **Click the icon** to open the app

See [INSTALL-NO-XCODE.md](INSTALL-NO-XCODE.md) for troubleshooting.

### Option 2: Use the Installer Package (Requires Full Xcode)

1. **Run the build script** to create the installer:
   ```bash
   cd WakeOnLAN
   ./build-installer.sh
   ```

2. **Double-click** the generated `WakeOnLAN-AppleSilicon-v1.0.pkg` file

3. **Follow the installer** - it will install to your Applications folder

4. **Look for the network icon** in your menu bar (top-right corner)

5. **Click the icon** to open the app

### Option 3: Build from Source with Xcode

1. **Open Terminal** and navigate to the WakeOnLAN folder

2. **Run the build script**:
   ```bash
   ./build.sh
   ```

3. Follow the prompts to:
   - Copy the app to Applications
   - Launch the app

### Option 2: Using Xcode

1. Open `WakeOnLAN.xcodeproj` in Xcode
2. Press ⌘R to build and run
3. Or use Product > Archive to create a distributable version

## First Time Setup

1. **Find the app** - Look in your menu bar (top-right) for a network icon
2. **Click the icon** - The Wake on LAN popover will appear
3. **Click the + button** to add your first target
4. **Add your first target**:

   Example for a typical Windows PC:
   ```
   Name:         Living Room PC
   IP Address:   192.168.1.100
   Subnet Mask:  255.255.255.0
   MAC Address:  00:11:22:33:44:55
   ```

4. **Click Save**

## Finding Your Device's MAC Address

### On Windows:
```cmd
ipconfig /all
```
Look for "Physical Address" under your network adapter

### On Linux:
```bash
ip link show
```
or
```bash
ifconfig
```

### On macOS:
```bash
ifconfig en0 | grep ether
```

## Enabling Wake-on-LAN on Your Devices

### Windows:
1. Open Device Manager
2. Find your network adapter
3. Right-click > Properties
4. Advanced tab > Enable "Wake on Magic Packet"
5. Power Management tab > Check "Allow this device to wake the computer"

### BIOS/UEFI (Most Important):
1. Restart computer and enter BIOS/UEFI (usually Del, F2, or F12)
2. Find Power Management or Network settings
3. Enable "Wake on LAN" or "WOL"
4. Save and exit

## Usage Tips

- **Same Network**: For best results, ensure your Mac and target devices are on the same network
- **Keep It Simple**: Start with the default subnet mask (255.255.255.0) for most home networks
- **Test Locally First**: Try waking a device on the same network before attempting remote wake
- **Cable Connection**: Wake-on-LAN works best with wired Ethernet connections

## Common Network Configurations

### Home Network (Most Common):
```
Subnet Mask: 255.255.255.0
IP Range:    192.168.1.x or 192.168.0.x
```

### Small Office:
```
Subnet Mask: 255.255.255.0
IP Range:    10.0.0.x or 172.16.0.x
```

## Troubleshooting

**Device won't wake?**
1. Check that WOL is enabled in BIOS
2. Verify the MAC address is correct
3. Ensure device is plugged into power
4. Try unplugging and replugging the network cable

**Can't find MAC address?**
- Make sure you're looking at the correct network adapter
- Wired (Ethernet) and wireless (WiFi) have different MAC addresses
- WOL typically only works over Ethernet

**App won't build?**
- **"xcodebuild requires Xcode"**: Use `./install-direct.sh` instead (works with just Command Line Tools)
- Ensure you have Xcode 14+ installed (or Command Line Tools for direct install)
- Check that your Mac is running macOS 13.0 (Ventura) or later
- Try cleaning the build: In Xcode, press ⌘⇧K

## Integration with Home Assistant

Since you're setting up Home Assistant Voice on your M4 Mac mini, you can use this app alongside it to:

1. Wake desktop PCs before running automation scripts
2. Create shortcuts to wake specific devices
3. Wake servers before accessing their services
4. Power on media centers before streaming

Consider creating AppleScript shortcuts to trigger WOL commands programmatically.

## Next Steps

- Add all your Wake-on-LAN capable devices
- Consider documenting your network layout
- Test each device to ensure WOL is working properly
- Explore AppleScript automation possibilities

Enjoy your new Wake on LAN app! 🚀
