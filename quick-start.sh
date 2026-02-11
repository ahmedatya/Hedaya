#!/bin/bash

# Quick start script - Just opens the iOS Simulator with iPhone 16

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Xcode is installed
check_xcode() {
    # Check if xcrun exists
    if ! command -v xcrun &> /dev/null; then
        echo -e "${RED}❌ Error: xcrun not found. Xcode is not installed.${NC}"
        echo ""
        echo -e "${YELLOW}To install Xcode, run:${NC}"
        echo -e "${BLUE}  ./install-xcode.sh${NC}"
        exit 1
    fi
    
    # Check if simctl binary exists
    if [ ! -f "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl" ]; then
        echo -e "${RED}❌ Error: simctl not found. Xcode components may not be fully installed.${NC}"
        echo ""
        echo -e "${BLUE}Checking for Xcode installation...${NC}"
        
        if [ -d "/Applications/Xcode.app" ]; then
            echo -e "${YELLOW}Found Xcode.app but components are missing.${NC}"
            echo -e "${BLUE}Run this command to set up Xcode:${NC}"
            echo "  ./setup-xcode.sh"
            exit 1
        else
            echo -e "${RED}Xcode.app not found in /Applications/${NC}"
            echo ""
            echo -e "${YELLOW}To install Xcode, run:${NC}"
            echo -e "${BLUE}  ./install-xcode.sh${NC}"
            exit 1
        fi
    fi
    
    # Check if we can access simctl (test with list command, ignore errors)
    # We'll test actual functionality when we try to use it
}

# Check Xcode first
check_xcode

# Try to open Simulator app
if ! open -a Simulator 2>/dev/null; then
    echo -e "${YELLOW}⚠ Could not open Simulator app directly. Trying alternative method...${NC}"
fi

# Boot iPhone 16 if available, otherwise boot the first available iPhone
DEVICE_UDID=$(xcrun simctl list devices available 2>/dev/null | grep "iPhone 16" | grep -oE '\([A-F0-9-]+\)' | head -1 | tr -d '()')

if [ -z "$DEVICE_UDID" ]; then
    # Fallback to first available iPhone
    DEVICE_UDID=$(xcrun simctl list devices available 2>/dev/null | grep "iPhone" | grep -oE '\([A-F0-9-]+\)' | head -1 | tr -d '()')
fi

if [ -n "$DEVICE_UDID" ]; then
    xcrun simctl boot "$DEVICE_UDID" 2>/dev/null
    echo -e "${GREEN}✓ Simulator started!${NC}"
else
    echo -e "${YELLOW}⚠ No iPhone simulator found. Simulator app should open manually.${NC}"
fi
