#!/bin/bash

# Fix iOS Simulator Issues for Hedaya
# This script diagnoses and fixes common Simulator problems

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   🔧 iOS Simulator Diagnostic & Fix Tool${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check if Xcode is installed
if [ ! -d "/Applications/Xcode.app" ]; then
    echo -e "${RED}❌ Xcode is not installed${NC}"
    echo ""
    echo -e "${BLUE}Run: ./install-xcode.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Xcode.app found${NC}"

# Check developer directory
CURRENT_DIR=$(xcode-select -p 2>/dev/null)
XCODE_DIR="/Applications/Xcode.app/Contents/Developer"

if [ "$CURRENT_DIR" != "$XCODE_DIR" ]; then
    echo -e "${YELLOW}⚠ Fixing developer directory...${NC}"
    sudo xcode-select --switch "$XCODE_DIR"
    echo -e "${GREEN}✓ Developer directory configured${NC}"
else
    echo -e "${GREEN}✓ Developer directory is correct${NC}"
fi

# Check if simctl exists
echo ""
echo -e "${BLUE}Checking simctl...${NC}"
if [ -f "$XCODE_DIR/usr/bin/simctl" ]; then
    echo -e "${GREEN}✓ simctl binary found${NC}"
else
    echo -e "${RED}❌ simctl binary not found${NC}"
    echo ""
    echo -e "${YELLOW}Xcode components are missing.${NC}"
    echo -e "${BLUE}Please open Xcode and let it install components.${NC}"
    exit 1
fi

# Test simctl
echo ""
echo -e "${BLUE}Testing simctl...${NC}"
SIMCTL_TEST=$(xcrun simctl list devices 2>&1)

if echo "$SIMCTL_TEST" | grep -qi "error\|invalid\|permission"; then
    echo -e "${YELLOW}⚠ simctl has connection issues${NC}"
    echo ""
    echo -e "${BLUE}This usually means:${NC}"
    echo "  • Xcode components aren't fully installed"
    echo "  • Simulator service needs to be started"
    echo ""
    
    # Try to open Simulator to start the service
    echo -e "${BLUE}Attempting to start Simulator service...${NC}"
    
    # Kill any stuck processes
    killall Simulator 2>/dev/null
    killall com.apple.CoreSimulator.CoreSimulatorService 2>/dev/null
    
    sleep 2
    
    # Try to open Simulator
    if open -a Simulator 2>/dev/null; then
        echo -e "${GREEN}✓ Simulator app opened${NC}"
        echo ""
        echo -e "${BLUE}Waiting for Simulator service to start...${NC}"
        sleep 5
        
        # Test again
        SIMCTL_TEST2=$(xcrun simctl list devices 2>&1)
        if ! echo "$SIMCTL_TEST2" | grep -qi "error\|invalid"; then
            echo -e "${GREEN}✓ Simulator service is now working!${NC}"
        else
            echo -e "${YELLOW}⚠ Still having issues. Trying to install components...${NC}"
            echo ""
            echo -e "${BLUE}Please:${NC}"
            echo "1. Open Xcode.app"
            echo "2. Go to Xcode → Settings → Platforms"
            echo "3. Make sure iOS Simulator runtime is installed"
            echo "4. Or run: xcodebuild -downloadPlatform iOS"
        fi
    else
        echo -e "${YELLOW}⚠ Could not open Simulator app${NC}"
        echo ""
        echo -e "${BLUE}Try manually:${NC}"
        echo "1. Open Xcode.app"
        echo "2. Wait for components to install"
        echo "3. Open Simulator from Xcode → Open Developer Tool → Simulator"
    fi
else
    echo -e "${GREEN}✓ simctl is working correctly!${NC}"
    echo ""
    echo -e "${GREEN}✅ Simulator is ready to use!${NC}"
    echo ""
    echo -e "${BLUE}You can now run:${NC}"
    echo "  ./quick-start.sh"
    echo "  ./start-simulator.sh start"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
