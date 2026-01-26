#!/bin/bash

# Wake on LAN Uninstaller
# Removes the app and its preferences

echo "Wake on LAN Uninstaller"
echo "======================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  This script needs administrator privileges."
    echo "Please run with sudo:"
    echo "  sudo ./uninstall.sh"
    exit 1
fi

APP_PATH="/Applications/WakeOnLAN.app"
PREFS_PATH="$HOME/Library/Preferences/com.wakeonlan.app.plist"

echo "This will remove:"
echo "  - $APP_PATH"
echo "  - User preferences"
echo ""

read -p "Are you sure you want to uninstall Wake on LAN? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Remove the app
if [ -d "$APP_PATH" ]; then
    echo "🗑️  Removing application..."
    rm -rf "$APP_PATH"
    echo "✅ Application removed"
else
    echo "⚠️  Application not found at $APP_PATH"
fi

# Remove preferences for all users (optional)
echo ""
read -p "Remove saved targets and preferences? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Remove for current user
    for USER_HOME in /Users/*; do
        USER_PREFS="$USER_HOME/Library/Preferences/com.wakeonlan.app.plist"
        if [ -f "$USER_PREFS" ]; then
            rm -f "$USER_PREFS"
            echo "✅ Removed preferences for $(basename $USER_HOME)"
        fi
    done
fi

echo ""
echo "✅ Uninstall complete!"
echo ""
