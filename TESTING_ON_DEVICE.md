# 📱 Testing Hedaya on Your Physical iOS Device

This guide will help you install and test the Hedaya app on your iPhone or iPad.

## Prerequisites

1. **Apple ID** (free account works for personal testing)
2. **USB Cable** to connect your device
3. **macOS** with Xcode installed
4. **iOS Device** (iPhone or iPad)

## Step-by-Step Guide

### Step 1: Connect Your Device

1. Connect your iPhone/iPad to your Mac using a USB cable
2. Unlock your device
3. If prompted, tap "Trust This Computer" on your device

### Step 2: Open the Project in Xcode

```bash
open Hedaya.xcodeproj
```

### Step 3: Configure Signing & Capabilities

1. In Xcode, click on the **Hedaya** project in the left sidebar (blue icon at the top)
2. Select the **Hedaya** target
3. Click on the **"Signing & Capabilities"** tab
4. Check **"Automatically manage signing"**
5. Select your **Team** (your Apple ID)
   - If you don't see your team, click "Add Account..." and sign in with your Apple ID
   - Xcode will create a free development certificate automatically

### Step 4: Select Your Device

1. At the top of Xcode, click on the device selector (next to the Play button)
2. You should see your connected device listed (e.g., "Ahmed's iPhone")
3. Select your device

### Step 5: Build and Run

1. Press `⌘R` (or click the Play button)
2. Xcode will build the app
3. On your device, you may see a prompt: **"Untrusted Developer"**
   - Go to: **Settings → General → VPN & Device Management** (or **Profiles & Device Management**)
   - Tap on your Apple ID under "Developer App"
   - Tap **"Trust [Your Name]"**
   - Tap **"Trust"** to confirm
4. The app will install and launch on your device!

## Troubleshooting

### "No devices found"
- Make sure your device is unlocked
- Check that you tapped "Trust This Computer"
- Try unplugging and replugging the USB cable
- Make sure you're using a data cable (not just charging cable)

### "Signing requires a development team"
- Make sure you're signed in to Xcode with your Apple ID
- Go to **Xcode → Settings → Accounts**
- Add your Apple ID if it's not there
- Select your team in Signing & Capabilities

### "Could not launch [app name]"
- Make sure you trusted the developer certificate (Step 5 above)
- Try uninstalling the app and reinstalling

### "Device is not connected"
- Check the USB cable connection
- Try a different USB port
- Restart Xcode
- Restart your device

## Free vs Paid Apple Developer Account

- **Free Account**: 
  - ✅ Works for personal testing
  - ✅ Apps expire after 7 days (need to reinstall)
  - ✅ Limited to 3 apps at a time
  - ❌ Cannot distribute to App Store

- **Paid Account ($99/year)**:
  - ✅ Apps don't expire
  - ✅ Can distribute to App Store
  - ✅ TestFlight beta testing
  - ✅ More capabilities

For testing purposes, the **free account is sufficient**.

## Quick Script

You can also use the provided script (see below) to help with some of these steps.

---

**Note**: The first time you install an app on your device, you need to trust the developer certificate in Settings. This is a one-time process per device.
