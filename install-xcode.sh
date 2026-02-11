#!/bin/bash

# Xcode Installation Helper for Hedaya
# This script helps you install Xcode from the App Store

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   📱 Xcode Installation Guide for Hedaya${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Check if Xcode is already installed
if [ -d "/Applications/Xcode.app" ]; then
    echo -e "${GREEN}✓ Xcode is already installed!${NC}"
    echo ""
    echo -e "${BLUE}Run the setup script to configure it:${NC}"
    echo "  ./setup-xcode.sh"
    exit 0
fi

echo -e "${YELLOW}Xcode is not installed.${NC}"
echo ""
echo -e "${BLUE}Xcode is required to:${NC}"
echo "  • Build iOS apps"
echo "  • Run the iOS Simulator"
echo "  • Develop for iPhone and iPad"
echo ""
echo -e "${YELLOW}⚠ Important Notes:${NC}"
echo "  • Xcode is large (~15GB download, ~30GB installed)"
echo "  • Installation can take 30-60 minutes depending on your internet"
echo "  • You need an Apple ID (free)"
echo "  • macOS 13.0 or later is required"
echo ""

# Check macOS version
MACOS_VERSION=$(sw_vers -productVersion)
echo -e "${BLUE}Your macOS version: ${CYAN}${MACOS_VERSION}${NC}"
echo ""

# Check available disk space
echo -e "${BLUE}Checking available disk space...${NC}"
AVAILABLE_SPACE=$(df -h / | tail -1 | awk '{print $4}')
echo -e "Available space: ${CYAN}${AVAILABLE_SPACE}${NC}"
echo ""

read -p "Would you like to open the App Store to install Xcode? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Opening App Store...${NC}"
    
    # Try to open Xcode in App Store
    if open "macappstore://apps.apple.com/app/xcode/id497799835" 2>/dev/null; then
        echo -e "${GREEN}✓ App Store opened!${NC}"
        echo ""
        echo -e "${BLUE}In the App Store:${NC}"
        echo "  1. Click 'Get' or 'Install'"
        echo "  2. Sign in with your Apple ID if prompted"
        echo "  3. Wait for download and installation to complete"
        echo ""
        echo -e "${YELLOW}After installation:${NC}"
        echo "  1. Open Xcode.app once to accept the license"
        echo "  2. Run: ./setup-xcode.sh"
        echo "  3. Then you can use: ./quick-start.sh"
    else
        echo -e "${YELLOW}Could not open App Store automatically.${NC}"
        echo ""
        echo -e "${BLUE}Please manually:${NC}"
        echo "  1. Open the App Store app"
        echo "  2. Search for 'Xcode'"
        echo "  3. Click 'Get' or 'Install'"
        echo ""
        echo -e "${BLUE}Or visit:${NC}"
        echo -e "${CYAN}https://apps.apple.com/app/xcode/id497799835${NC}"
    fi
else
    echo ""
    echo -e "${BLUE}To install Xcode manually:${NC}"
    echo ""
    echo "  1. Open the App Store app"
    echo "  2. Search for 'Xcode'"
    echo "  3. Click 'Get' or 'Install'"
    echo ""
    echo -e "${BLUE}Or visit:${NC}"
    echo -e "${CYAN}https://apps.apple.com/app/xcode/id497799835${NC}"
    echo ""
    echo -e "${YELLOW}After installation, run:${NC}"
    echo "  ./setup-xcode.sh"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
