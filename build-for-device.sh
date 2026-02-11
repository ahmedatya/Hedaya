#!/bin/bash

# Build and Install Hedaya on Physical iOS Device
# This script helps prepare and build for a connected device

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   📱 Building Hedaya for Physical Device${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ xcodebuild not found. Xcode is not installed.${NC}"
    exit 1
fi

# Check for connected devices
echo -e "${BLUE}Checking for connected iOS devices...${NC}"
DEVICES=$(xcrun xctrace list devices 2>/dev/null | grep -E "iPhone|iPad" | grep -v "Simulator" || echo "")

if [ -z "$DEVICES" ]; then
    echo -e "${YELLOW}⚠ No physical devices detected.${NC}"
    echo ""
    echo -e "${BLUE}Make sure:${NC}"
    echo "  1. Your device is connected via USB"
    echo "  2. Your device is unlocked"
    echo "  3. You tapped 'Trust This Computer' on your device"
    echo ""
    echo -e "${YELLOW}Alternatively, you can build from Xcode:${NC}"
    echo "  1. open Hedaya.xcodeproj"
    echo "  2. Select your device from the device menu"
    echo "  3. Press ⌘R"
    exit 1
fi

echo -e "${GREEN}✓ Found connected device(s):${NC}"
echo "$DEVICES" | sed 's/^/  /'
echo ""

# List devices using xcodebuild
echo -e "${BLUE}Available destinations:${NC}"
xcodebuild -project Hedaya.xcodeproj -scheme Hedaya -showdestinations 2>/dev/null | grep -E "iOS|id:" | head -10 || echo "  (Could not list destinations)"

echo ""
echo -e "${YELLOW}⚠ Important: Before building, make sure:${NC}"
echo ""
echo "  1. You've configured signing in Xcode:"
echo "     - Open: open Hedaya.xcodeproj"
echo "     - Select project → Signing & Capabilities"
echo "     - Check 'Automatically manage signing'"
echo "     - Select your Team (Apple ID)"
echo ""
echo "  2. Your device is trusted:"
echo "     - Settings → General → VPN & Device Management"
echo "     - Trust your developer certificate"
echo ""

read -p "Have you configured signing in Xcode? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}Please configure signing first:${NC}"
    echo "  1. open Hedaya.xcodeproj"
    echo "  2. Select project → Signing & Capabilities"
    echo "  3. Check 'Automatically manage signing'"
    echo "  4. Select your Team"
    echo ""
    echo -e "${YELLOW}Then run this script again.${NC}"
    exit 0
fi

# Get device UDID (first connected device)
DEVICE_UDID=$(xcrun xctrace list devices 2>/dev/null | grep -E "iPhone|iPad" | grep -v "Simulator" | head -1 | grep -oE '\([A-F0-9-]+\)' | tr -d '()' || echo "")

if [ -z "$DEVICE_UDID" ]; then
    echo -e "${YELLOW}⚠ Could not get device UDID. Building for generic iOS device...${NC}"
    DESTINATION="generic/platform=iOS"
else
    DEVICE_NAME=$(xcrun xctrace list devices 2>/dev/null | grep "$DEVICE_UDID" | sed 's/.*\(iPhone\|iPad\).*/\1/' | head -1)
    echo -e "${BLUE}Building for: ${DEVICE_NAME} (${DEVICE_UDID})${NC}"
    DESTINATION="id=$DEVICE_UDID"
fi

echo ""
echo -e "${BLUE}Building app...${NC}"

# Build for device
xcodebuild -project Hedaya.xcodeproj \
          -scheme Hedaya \
          -destination "platform=iOS,$DESTINATION" \
          -configuration Debug \
          build

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}❌ Build failed${NC}"
    echo ""
    echo -e "${YELLOW}Common issues:${NC}"
    echo "  • Signing not configured - check Xcode Signing & Capabilities"
    echo "  • No team selected - add your Apple ID in Xcode Settings"
    echo "  • Device not trusted - trust the developer certificate on device"
    echo ""
    echo -e "${BLUE}Try building from Xcode instead (⌘R)${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Build successful!${NC}"
echo ""

# Find the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Hedaya.app" -type d -path "*/Build/Products/Debug-iphoneos/*" 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Hedaya.app" -type d 2>/dev/null | head -1)
fi

if [ -z "$APP_PATH" ]; then
    echo -e "${YELLOW}⚠ Could not find built app automatically${NC}"
    echo ""
    echo -e "${BLUE}The app was built successfully.${NC}"
    echo -e "${BLUE}To install it, use Xcode:${NC}"
    echo "  1. Select your device in Xcode"
    echo "  2. Press ⌘R to build and install"
    exit 0
fi

echo -e "${GREEN}✓ Found app: ${APP_PATH}${NC}"
echo ""

# Install using xcrun devicectl (newer method) or ideviceinstaller
echo -e "${BLUE}Installing on device...${NC}"

if command -v xcrun &> /dev/null && xcrun devicectl &> /dev/null 2>&1; then
    # iOS 17+ method
    xcrun devicectl device install app --device "$DEVICE_UDID" "$APP_PATH" 2>/dev/null
    INSTALL_SUCCESS=$?
elif command -v ideviceinstaller &> /dev/null; then
    # Alternative method (requires libimobiledevice)
    ideviceinstaller -u "$DEVICE_UDID" -i "$APP_PATH"
    INSTALL_SUCCESS=$?
else
    echo -e "${YELLOW}⚠ Automatic installation not available${NC}"
    echo ""
    echo -e "${BLUE}To install the app:${NC}"
    echo "  1. Open Xcode"
    echo "  2. Select your device"
    echo "  3. Press ⌘R"
    echo ""
    echo -e "${BLUE}Or use Xcode's Window → Devices and Simulators${NC}"
    INSTALL_SUCCESS=1
fi

if [ $INSTALL_SUCCESS -eq 0 ]; then
    echo -e "${GREEN}✓ App installed!${NC}"
    echo ""
    echo -e "${BLUE}If you see 'Untrusted Developer' on your device:${NC}"
    echo "  Settings → General → VPN & Device Management"
    echo "  → Trust your developer certificate"
else
    echo ""
    echo -e "${YELLOW}Installation via command line had issues.${NC}"
    echo ""
    echo -e "${BLUE}To install the app, use Xcode:${NC}"
    echo "  1. open Hedaya.xcodeproj"
    echo "  2. Select your device from the device menu"
    echo "  3. Press ⌘R"
    echo ""
    echo -e "${GREEN}The app is built and ready to install!${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
