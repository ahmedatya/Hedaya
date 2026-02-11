#!/bin/bash

# Build and Run Hedaya App on iOS Simulator
# This script builds the app and installs it on the running simulator

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

set -e

# Default device
DEFAULT_DEVICE="iPhone 16"

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   📱 Building and Running Hedaya App${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ xcodebuild not found. Xcode is not installed.${NC}"
    echo ""
    echo -e "${BLUE}Run: ./install-xcode.sh${NC}"
    exit 1
fi

# Get device name (optional argument)
DEVICE_NAME="${1:-$DEFAULT_DEVICE}"

# Check if simulator is running and get its name
echo -e "${BLUE}Checking if simulator is running...${NC}"
BOOTED_INFO=$(xcrun simctl list devices | grep "Booted" | head -1)
BOOTED_DEVICE_UDID=$(echo "$BOOTED_INFO" | grep -oE '\([A-F0-9-]+\)' | head -1 | tr -d '()' || echo "")
BOOTED_DEVICE_NAME=$(echo "$BOOTED_INFO" | sed 's/.*Booted[[:space:]]*\([^(]*\).*/\1/' | sed 's/[[:space:]]*$//' || echo "")

if [ -z "$BOOTED_DEVICE_UDID" ]; then
    echo -e "${YELLOW}⚠ No simulator is currently running.${NC}"
    echo -e "${BLUE}Starting simulator: ${DEVICE_NAME}${NC}"
    
    # Start simulator using our script
    ./start-simulator.sh start "$DEVICE_NAME"
    
    # Wait a bit for simulator to be ready
    sleep 5
    
    # Get the booted device again
    BOOTED_INFO=$(xcrun simctl list devices | grep "Booted" | head -1)
    BOOTED_DEVICE_UDID=$(echo "$BOOTED_INFO" | grep -oE '\([A-F0-9-]+\)' | head -1 | tr -d '()' || echo "")
    BOOTED_DEVICE_NAME=$(echo "$BOOTED_INFO" | sed 's/.*Booted[[:space:]]*\([^(]*\).*/\1/' | sed 's/[[:space:]]*$//' || echo "")
    
    if [ -z "$BOOTED_DEVICE_UDID" ]; then
        echo -e "${RED}❌ Failed to start simulator${NC}"
        exit 1
    fi
    
    # Use the actual booted device name
    if [ -n "$BOOTED_DEVICE_NAME" ]; then
        DEVICE_NAME="$BOOTED_DEVICE_NAME"
    fi
else
    echo -e "${GREEN}✓ Simulator is running: ${BOOTED_DEVICE_NAME:-$DEVICE_NAME}${NC}"
    # Use the actual booted device name if available
    if [ -n "$BOOTED_DEVICE_NAME" ]; then
        DEVICE_NAME="$BOOTED_DEVICE_NAME"
    fi
fi

# Build the app
echo ""
echo -e "${BLUE}Building Hedaya app for: ${DEVICE_NAME}${NC}"
echo ""

# Use the same approach as Xcode - build and run in one command
# This matches what Xcode does when you press ⌘R
BUILD_OUTPUT=$(xcodebuild -project Hedaya.xcodeproj \
          -scheme Hedaya \
          -destination "platform=iOS Simulator,name=$DEVICE_NAME" \
          -derivedDataPath ./build \
          -configuration Debug \
          build 2>&1)

BUILD_EXIT_CODE=$?

# Show build output
echo "$BUILD_OUTPUT"

if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠ Build with scheme failed. Trying alternative method...${NC}"
    echo ""
    
    # Alternative: Use xcodebuild build-for-testing which is more reliable
    if ! xcodebuild -project Hedaya.xcodeproj \
              -scheme Hedaya \
              -destination "platform=iOS Simulator,id=$BOOTED_DEVICE_UDID" \
              -derivedDataPath ./build \
              -configuration Debug \
              build 2>&1; then
        echo ""
        echo -e "${RED}❌ Build failed${NC}"
        echo ""
        echo -e "${YELLOW}The app works in Xcode, so you can:${NC}"
        echo "  1. Keep using Xcode (⌘R to build and run)"
        echo "  2. Or check the build output above for specific errors"
        echo ""
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}✓ Build successful!${NC}"

# Find the built app - Xcode puts it in Build/Products/Debug-iphonesimulator
APP_PATH=$(find ./build -name "Hedaya.app" -type d | head -1)

# Alternative locations to check
if [ -z "$APP_PATH" ]; then
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Hedaya.app" -type d 2>/dev/null | head -1)
fi

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ Could not find built app${NC}"
    echo ""
    echo -e "${YELLOW}The build may have succeeded but the app location is different.${NC}"
    echo -e "${BLUE}Try building from Xcode instead (⌘R)${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found app at: ${APP_PATH}${NC}"

echo ""
echo -e "${BLUE}Installing app on simulator...${NC}"

# Install the app
xcrun simctl install booted "$APP_PATH"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Installation failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ App installed!${NC}"

# Launch the app
echo ""
echo -e "${BLUE}Launching Hedaya app...${NC}"

xcrun simctl launch booted com.hedaya.app

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ App launched successfully!${NC}"
    echo ""
    echo -e "${BLUE}The Hedaya app should now be visible on your simulator.${NC}"
else
    echo -e "${YELLOW}⚠ Launch command completed (app may already be running)${NC}"
    echo ""
    echo -e "${BLUE}The app should be visible on your simulator.${NC}"
    echo -e "${BLUE}If not, look for the Hedaya app icon on the home screen.${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
