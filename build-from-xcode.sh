#!/bin/bash

# Build and Run using Xcode's build system
# This script uses xcodebuild in a way that matches Xcode's behavior

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📱 Building Hedaya using Xcode build system...${NC}"
echo ""

# Check if simulator is running
BOOTED_DEVICE=$(xcrun simctl list devices | grep "Booted" | head -1 || echo "")

if [ -z "$BOOTED_DEVICE" ]; then
    echo -e "${YELLOW}⚠ No simulator is running.${NC}"
    echo -e "${BLUE}Starting simulator...${NC}"
    ./quick-start.sh
    sleep 3
fi

# Get the booted device UDID
BOOTED_UDID=$(xcrun simctl list devices | grep "Booted" | grep -oE '\([A-F0-9-]+\)' | head -1 | tr -d '()' || echo "")

if [ -z "$BOOTED_UDID" ]; then
    echo -e "${RED}❌ Could not determine booted simulator${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Simulator is running${NC}"
echo ""

# Build using xcodebuild - this matches what Xcode does
echo -e "${BLUE}Building app...${NC}"

# Use xcodebuild with the same settings Xcode uses
xcodebuild -project Hedaya.xcodeproj \
          -scheme Hedaya \
          -destination "generic/platform=iOS Simulator" \
          -configuration Debug \
          build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    echo ""
    echo -e "${YELLOW}Since it works in Xcode, try:${NC}"
    echo "  1. Open Hedaya.xcodeproj in Xcode"
    echo "  2. Press ⌘R to build and run"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Build successful!${NC}"

# Find the app in the default DerivedData location (where Xcode puts it)
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Hedaya.app" -type d -path "*/Build/Products/Debug-iphonesimulator/*" 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
    # Try alternative location
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Hedaya.app" -type d 2>/dev/null | head -1)
fi

if [ -z "$APP_PATH" ]; then
    echo -e "${YELLOW}⚠ Could not find built app automatically${NC}"
    echo ""
    echo -e "${BLUE}The app was built successfully.${NC}"
    echo -e "${BLUE}Since it works in Xcode, the easiest way is to use Xcode:${NC}"
    echo "  open Hedaya.xcodeproj"
    echo ""
    echo -e "${BLUE}Then press ⌘R to run.${NC}"
    exit 0
fi

echo -e "${GREEN}✓ Found app: ${APP_PATH}${NC}"
echo ""

# Install on simulator
echo -e "${BLUE}Installing on simulator...${NC}"
xcrun simctl install "$BOOTED_UDID" "$APP_PATH"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Installed!${NC}"
    echo ""
    
    # Launch
    echo -e "${BLUE}Launching app...${NC}"
    xcrun simctl launch "$BOOTED_UDID" com.hedaya.app
    
    echo ""
    echo -e "${GREEN}✅ Done! The app should be visible on your simulator.${NC}"
else
    echo -e "${YELLOW}⚠ Installation had issues, but the app might still work${NC}"
    echo -e "${BLUE}Check your simulator for the Hedaya app icon.${NC}"
fi
