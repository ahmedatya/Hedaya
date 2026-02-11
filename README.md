# 🕌 Hedaya (هداية) - iOS Azkar App

A beautiful iOS application for reciting Azkar (Islamic remembrances) with an interactive counter.

**License:** This project is under a custom license. See [LICENSE](LICENSE). You may contribute to this repo but may not fork or reuse the code, design, or ideas elsewhere.

## Features

- 📱 **5 Azkar Groups**: Morning, Evening, After Prayer, Sleep, and Miscellaneous
- 🔢 **Interactive Counter**: Tap the white dot to count each Zikr
- ✨ **Auto-Advance**: Automatically moves to the next Zikr when count is reached
- 🎨 **Beautiful UI**: Modern design with gradient colors and smooth animations
- 🌙 **RTL Support**: Full right-to-left layout for Arabic text

## Quick Start

### Option 1: Using Xcode (Recommended)

1. Open `Hedaya.xcodeproj` in Xcode
2. Select an iOS Simulator (e.g., iPhone 16)
3. Press `⌘R` to build and run

### Option 2: Using Scripts

#### Quick Start Script (Just opens simulator)
```bash
./quick-start.sh
```

#### Build and Run the App

**Option 1: Using Xcode (Recommended - Most Reliable)**
```bash
open Hedaya.xcodeproj
# Then press ⌘R in Xcode
```

**Option 2: Command Line Scripts**
```bash
# Method 1: Use Xcode's build system (recommended if Xcode works)
./build-from-xcode.sh

# Method 2: Direct build script
./build-and-run.sh

# Or specify a device
./build-and-run.sh "iPhone 15"
```

#### Full Script (Start simulator + build + run)
```bash
# Start simulator only
./start-simulator.sh start

# Start specific device
./start-simulator.sh start "iPhone 15"

# List all available simulators
./start-simulator.sh list

# Build and run the app (uses build-and-run.sh)
./start-simulator.sh run
```

## Project Structure

```
Hedaya/
├── HedayaApp.swift          # App entry point
├── Models.swift             # Data models (Zikr, AzkarGroup)
├── AzkarData.swift          # All Arabic Azkar content
├── ContentView.swift        # Main screen with group cards
├── AzkarGroupView.swift     # Zikr counter screen
├── ZikrCounterView.swift    # Reusable components
└── Assets.xcassets/         # App assets
```

## Requirements

- **Xcode 15.0 or later** (full app, not just Command Line Tools)
- iOS 17.0 or later
- macOS 13.0 or later

## Setup

### First Time Setup

If you encounter errors like "unable to find utility 'simctl'" or "Unable to find application named 'Simulator'", you need to install and set up Xcode:

#### Step 1: Install Xcode

Run the installation helper:
```bash
./install-xcode.sh
```

This script will:
- Check if Xcode is already installed
- Open the App Store to install Xcode
- Provide installation guidance

**Note:** Xcode is large (~15GB download) and installation can take 30-60 minutes.

#### Step 2: Configure Xcode

After Xcode is installed, run the setup script:
```bash
./setup-xcode.sh
```

This script will:
- Check if Xcode is installed
- Configure Xcode as the active developer directory
- Verify the iOS Simulator tools are available

#### Step 3: Fix Simulator Issues (if needed)

If you see "iOS Simulator tools are not available", run:
```bash
./fix-simulator.sh
```

This script will:
- Diagnose Simulator issues
- Fix common problems
- Start the Simulator service
- Guide you through component installation

#### Step 4: Verify Setup

Test the simulator:
```bash
./quick-start.sh
```

If you see "✓ Simulator started!", you're all set!

#### Manual Setup (Alternative)

If the scripts don't work, you can set up manually:

1. **Install Xcode** from the App Store
2. **Configure Xcode**:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   ```
3. **Open Xcode once** to accept the license agreement

### Verify Setup

After setup, test the simulator:
```bash
./quick-start.sh
```

If you see "✓ Simulator started!", you're all set!

## How to Use

1. **Select a Group**: Tap on any Azkar group from the main screen
2. **Read the Zikr**: The Arabic text and reference are displayed
3. **Count**: Tap the white circle in the center to increment the counter
4. **Auto-Advance**: When you reach the recommended count, it automatically moves to the next Zikr
5. **Navigate**: Use Previous/Next buttons to move between Azkar manually
6. **Complete**: When all Azkar in a group are finished, a completion screen appears

## Azkar Groups

- ☀️ **أذكار الصباح** (Morning Azkar) - 14 remembrances
- 🌙 **أذكار المساء** (Evening Azkar) - 14 remembrances
- 🤲 **أذكار بعد الصلاة** (After Prayer Azkar) - 7 remembrances
- 🛏️ **أذكار النوم** (Sleep Azkar) - 6 remembrances
- ✨ **أذكار متنوعة** (Miscellaneous Azkar) - 4 remembrances

## Deploy to Your Device

To install and run Hedaya on your iPhone or iPad:

### Quick Start

1. **Connect your device** via USB and unlock it
2. **Open the project**: `open Hedaya.xcodeproj`
3. **Select your device** from the device menu (top toolbar)
4. **Configure signing** (one-time):
   - Click on the project (blue icon) → Select "Hedaya" target
   - Go to "Signing & Capabilities" tab
   - Check "Automatically manage signing"
   - Select your Team (Apple ID)
5. **Press ⌘R** to build and install
6. **Trust the developer** on your device (first time only):
   - Settings → General → VPN & Device Management
   - Tap your Apple ID → Trust

### Complete Guide

📖 **See `DEPLOY_TO_DEVICE.md` for detailed step-by-step instructions** including:
- Complete deployment process
- Troubleshooting common issues
- Free vs paid developer accounts
- Tips and best practices

**Having provisioning issues?** See `FIX_PROVISIONING.md` for help with device registration errors.

### Command Line Method

```bash
./build-for-device.sh
```

**Note**: You still need to configure signing in Xcode first (see Quick Start above).

## App Icon

To generate the app icon:

```bash
# Install Pillow (if not already installed)
pip3 install Pillow

# Generate icons
python3 generate-icon.py
```

Or see `ICON_GUIDE.md` for detailed instructions and alternative methods.

The icon features a green gradient background with a crescent moon and star, matching the Islamic theme of the app.

## License

This project is created for personal/educational use.

---

**بارك الله فيك** - May Allah bless you
