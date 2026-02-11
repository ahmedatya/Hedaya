#!/bin/bash

# Hedaya - iOS Simulator Startup Script
# This script starts the iOS Simulator and optionally builds/runs the app

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default device (iPhone 16)
DEFAULT_DEVICE="iPhone 16"

# Check if Xcode is installed and configured
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
            echo -e "${YELLOW}✓ Found Xcode.app but components are missing.${NC}"
            echo ""
            echo -e "${BLUE}Current developer directory:${NC}"
            xcode-select -p 2>/dev/null || echo "Not set"
            echo ""
            echo -e "${BLUE}Run this command to set up Xcode:${NC}"
            echo "  ./setup-xcode.sh"
            exit 1
        else
            echo -e "${RED}✗ Xcode.app not found in /Applications/${NC}"
            echo ""
            echo -e "${YELLOW}To install Xcode, run:${NC}"
            echo -e "${BLUE}  ./install-xcode.sh${NC}"
            echo ""
            echo "This will guide you through the installation process."
            exit 1
        fi
    fi
    
    # If we get here, simctl exists - we'll test actual functionality when we use it
}

# Function to list available simulators
list_simulators() {
    check_xcode
    echo -e "${BLUE}Available iOS Simulators:${NC}"
    xcrun simctl list devices available 2>/dev/null | grep -E "iPhone|iPad" | sed 's/^[[:space:]]*//' | head -20 || {
        echo -e "${RED}Error: Could not list simulators.${NC}"
        exit 1
    }
}

# Function to get device UDID by name
get_device_udid() {
    local device_name="$1"
    xcrun simctl list devices available 2>/dev/null | grep "$device_name" | grep -oE '\([A-F0-9-]+\)' | head -1 | tr -d '()'
}

# Function to start simulator
start_simulator() {
    check_xcode
    
    local device_name="${1:-$DEFAULT_DEVICE}"
    
    echo -e "${BLUE}Starting iOS Simulator: ${device_name}${NC}"
    
    # Get device UDID
    local device_udid=$(get_device_udid "$device_name")
    
    if [ -z "$device_udid" ]; then
        echo -e "${YELLOW}Warning: Device '$device_name' not found. Trying to boot default device...${NC}"
        # Try to boot the first available iPhone
        device_udid=$(xcrun simctl list devices available 2>/dev/null | grep "iPhone" | grep -oE '\([A-F0-9-]+\)' | head -1 | tr -d '()')
        
        if [ -z "$device_udid" ]; then
            echo -e "${YELLOW}Error: No available iPhone simulator found.${NC}"
            list_simulators
            exit 1
        fi
    fi
    
    # Boot the simulator
    echo -e "${BLUE}Booting simulator...${NC}"
    xcrun simctl boot "$device_udid" 2>/dev/null || echo -e "${YELLOW}Simulator may already be running${NC}"
    
    # Open Simulator app
    if ! open -a Simulator 2>/dev/null; then
        echo -e "${YELLOW}⚠ Could not open Simulator app directly. It may already be open.${NC}"
    fi
    
    # Wait for simulator to be ready
    echo -e "${BLUE}Waiting for simulator to be ready...${NC}"
    sleep 3
    
    echo -e "${GREEN}✓ Simulator started successfully!${NC}"
}

# Function to build and run the app
build_and_run() {
    check_xcode
    
    local device_name="${1:-$DEFAULT_DEVICE}"
    
    echo -e "${BLUE}Building and running Hedaya app...${NC}"
    echo ""
    echo -e "${YELLOW}Note: Using dedicated build script for better reliability${NC}"
    echo ""
    
    # Use the dedicated build script
    if [ -f "./build-and-run.sh" ]; then
        ./build-and-run.sh "$device_name"
    else
        echo -e "${YELLOW}⚠ build-and-run.sh not found. Using basic build method...${NC}"
        
        # Start simulator first
        start_simulator "$device_name"
        
        # Build and run
        echo -e "${BLUE}Building project...${NC}"
        xcodebuild -project Hedaya.xcodeproj \
                  -scheme Hedaya \
                  -destination "platform=iOS Simulator,name=$device_name" \
                  -derivedDataPath ./build \
                  clean build
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Build successful!${NC}"
            echo -e "${BLUE}Installing and launching app...${NC}"
            
            # Find and install the app
            APP_PATH=$(find ./build -name "Hedaya.app" -type d | head -1)
            if [ -n "$APP_PATH" ]; then
                xcrun simctl install booted "$APP_PATH"
                xcrun simctl launch booted com.hedaya.app
                echo -e "${GREEN}✓ App launched successfully!${NC}"
            else
                echo -e "${RED}❌ Could not find built app${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}Build failed. Simulator is still running.${NC}"
            exit 1
        fi
    fi
}

# Main script logic
case "${1:-start}" in
    start)
        start_simulator "${2:-$DEFAULT_DEVICE}"
        ;;
    list)
        list_simulators
        ;;
    run)
        build_and_run "${2:-$DEFAULT_DEVICE}"
        ;;
    *)
        echo "Usage: $0 [start|list|run] [device_name]"
        echo ""
        echo "Commands:"
        echo "  start [device]  - Start the iOS Simulator (default: iPhone 16)"
        echo "  list            - List all available simulators"
        echo "  run [device]    - Start simulator, build and run the app"
        echo ""
        echo "Examples:"
        echo "  $0 start              # Start default iPhone 16 simulator"
        echo "  $0 start 'iPhone 15' # Start iPhone 15 simulator"
        echo "  $0 list               # List all available simulators"
        echo "  $0 run                # Start simulator and run the app"
        exit 1
        ;;
esac
