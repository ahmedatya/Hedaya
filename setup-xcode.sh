#!/bin/bash

# Xcode Setup Helper Script for Hedaya
# This script helps configure Xcode for iOS development

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Xcode Setup Helper for Hedaya${NC}"
echo ""

# Check if Xcode is installed
if [ ! -d "/Applications/Xcode.app" ]; then
    echo -e "${RED}❌ Xcode is not installed.${NC}"
    echo ""
    echo -e "${YELLOW}To install Xcode, run:${NC}"
    echo -e "${BLUE}  ./install-xcode.sh${NC}"
    echo ""
    echo "This will guide you through the installation process."
    echo ""
    echo -e "${BLUE}After installation, run this script again.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Xcode.app found${NC}"

# Check current developer directory
CURRENT_DIR=$(xcode-select -p 2>/dev/null)
XCODE_DIR="/Applications/Xcode.app/Contents/Developer"

echo -e "${BLUE}Current developer directory:${NC} $CURRENT_DIR"
echo ""

if [ "$CURRENT_DIR" != "$XCODE_DIR" ]; then
    echo -e "${YELLOW}⚠ Xcode is not configured as the active developer directory.${NC}"
    echo ""
    echo -e "${BLUE}This script will configure Xcode. You may be prompted for your password.${NC}"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Configuring Xcode...${NC}"
        sudo xcode-select --switch "$XCODE_DIR"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Xcode configured successfully!${NC}"
        else
            echo -e "${RED}❌ Failed to configure Xcode. Please run manually:${NC}"
            echo "sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
            exit 1
        fi
    else
        echo -e "${YELLOW}Cancelled.${NC}"
        exit 0
    fi
else
    echo -e "${GREEN}✓ Xcode is already configured correctly${NC}"
fi

# Check if license is accepted
echo ""
echo -e "${BLUE}Checking Xcode license agreement...${NC}"
if ! xcodebuild -version &> /dev/null; then
    echo -e "${YELLOW}⚠ Xcode license may not be accepted.${NC}"
    echo ""
    echo -e "${BLUE}You need to:${NC}"
    echo "1. Open Xcode.app"
    echo "2. Accept the license agreement when prompted"
    echo ""
    read -p "Open Xcode now? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open -a Xcode
        echo -e "${BLUE}Please accept the license agreement in Xcode, then run this script again.${NC}"
        exit 0
    fi
else
    echo -e "${GREEN}✓ Xcode license accepted${NC}"
fi

# Check if simctl is available
echo ""
echo -e "${BLUE}Checking iOS Simulator tools...${NC}"

# Check if simctl binary exists
if [ ! -f "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl" ]; then
    echo -e "${RED}❌ simctl binary not found${NC}"
    echo ""
    echo -e "${YELLOW}Xcode components may not be fully installed.${NC}"
    echo ""
    echo -e "${BLUE}Please:${NC}"
    echo "1. Open Xcode.app"
    echo "2. Wait for 'Installing Components' to complete"
    echo "3. If prompted, install additional components"
    echo "4. Run this script again"
    exit 1
fi

# Try to run simctl (suppress errors for testing)
SIMCTL_OUTPUT=$(xcrun simctl list devices 2>&1)
SIMCTL_ERROR=$(echo "$SIMCTL_OUTPUT" | grep -i "error\|invalid\|permission" | head -1)

if [ -n "$SIMCTL_ERROR" ]; then
    echo -e "${YELLOW}⚠ iOS Simulator service issue detected${NC}"
    echo ""
    echo -e "${BLUE}This usually means Xcode needs additional components.${NC}"
    echo ""
    echo -e "${YELLOW}Try these steps:${NC}"
    echo ""
    echo "1. Open Xcode.app:"
    echo "   open -a Xcode"
    echo ""
    echo "2. Wait for any 'Installing Components' dialog to complete"
    echo ""
    echo "3. Go to Xcode → Settings → Platforms (or Components)"
    echo "   Make sure iOS Simulator is installed"
    echo ""
    echo "4. Alternatively, try installing via command line:"
    echo "   xcodebuild -downloadPlatform iOS"
    echo ""
    echo "5. After components are installed, run this script again"
    echo ""
    echo -e "${BLUE}Or try the fix script:${NC}"
    echo "   ./fix-simulator.sh"
    echo ""
    echo -e "${BLUE}If the issue persists, you can still try opening the Simulator:${NC}"
    echo "   open -a Simulator"
    echo ""
    read -p "Would you like to open Xcode now to install components? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open -a Xcode
        echo -e "${BLUE}Xcode opened. Please wait for components to install, then run:${NC}"
        echo -e "${CYAN}  ./fix-simulator.sh${NC}"
        exit 0
    fi
    
    echo ""
    echo -e "${BLUE}You can also try running the fix script:${NC}"
    echo -e "${CYAN}  ./fix-simulator.sh${NC}"
    exit 1
else
    echo -e "${GREEN}✓ iOS Simulator tools are available${NC}"
    echo ""
    echo -e "${GREEN}✅ Setup complete! You can now use the simulator scripts.${NC}"
    echo ""
    echo -e "${BLUE}Try running:${NC}"
    echo "  ./quick-start.sh      # Quick start simulator"
    echo "  ./start-simulator.sh  # Full simulator script"
fi
