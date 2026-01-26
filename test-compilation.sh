#!/bin/bash

# Test Swift Compilation
# This script tests if we can compile Swift code successfully

echo "🧪 Testing Swift Compilation"
echo "============================"
echo ""

# Check Swift compiler
echo "1. Checking Swift compiler..."
if ! command -v swiftc &> /dev/null; then
    echo "   ❌ swiftc not found!"
    echo "   Install Command Line Tools: xcode-select --install"
    exit 1
fi
echo "   ✓ swiftc found: $(which swiftc)"

# Check Swift version
echo ""
echo "2. Swift version:"
swiftc --version

# Check SDK
echo ""
echo "3. Checking SDK..."
SDK_PATH=$(xcrun --show-sdk-path 2>/dev/null)
if [ -z "$SDK_PATH" ]; then
    echo "   ❌ SDK not found!"
    exit 1
fi
echo "   ✓ SDK: $SDK_PATH"

# Check architecture
echo ""
echo "4. System architecture:"
uname -m

# Test compile a simple Swift program
echo ""
echo "5. Testing basic Swift compilation..."
cat > /tmp/test_swift.swift << 'EOF'
import Foundation
print("Hello from Swift!")
EOF

swiftc -target arm64-apple-macos13.0 -sdk "$SDK_PATH" /tmp/test_swift.swift -o /tmp/test_swift

if [ $? -eq 0 ] && [ -f /tmp/test_swift ]; then
    echo "   ✓ Basic compilation works!"
    /tmp/test_swift
    rm /tmp/test_swift /tmp/test_swift.swift
else
    echo "   ❌ Basic compilation failed!"
    exit 1
fi

# Test compile with SwiftUI
echo ""
echo "6. Testing SwiftUI compilation..."
cat > /tmp/test_swiftui.swift << 'EOF'
import SwiftUI

@main
struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Test")
        }
    }
}
EOF

swiftc -target arm64-apple-macos13.0 -sdk "$SDK_PATH" -parse-as-library /tmp/test_swiftui.swift -o /tmp/test_swiftui 2>&1

if [ $? -eq 0 ] && [ -f /tmp/test_swiftui ]; then
    echo "   ✓ SwiftUI compilation works!"
    file /tmp/test_swiftui
    rm /tmp/test_swiftui /tmp/test_swiftui.swift
else
    echo "   ❌ SwiftUI compilation failed!"
    echo ""
    echo "This means you might need full Xcode to build SwiftUI apps."
    echo "Install Xcode from the App Store, then use ./build-installer.sh instead."
    rm -f /tmp/test_swiftui.swift
    exit 1
fi

echo ""
echo "✅ All tests passed!"
echo ""
echo "Your system can compile Swift code with SwiftUI."
echo "You should be able to run: ./install-direct.sh"
echo ""
