# 🎨 Creating the Hedaya App Icon

This guide will help you create and set up the app icon for Hedaya.

## Quick Method: Generate Icon Automatically

### Step 1: Install Pillow (Python library)

```bash
pip3 install Pillow
```

If you get permission errors, try:
```bash
pip3 install --user Pillow
```

### Step 2: Generate Icons

```bash
./generate-icon.py
```

This will create all required icon sizes automatically in the correct location.

## Icon Design

The generated icon features:
- **Green gradient background** (Islamic theme colors: #1B7A4A and #2ECC71)
- **Crescent moon** (white crescent on green background)
- **Star** (small white star next to crescent)
- **Circular design** with elegant borders

## Alternative Methods

### Method 1: Use Online Icon Generator

1. Create a 1024x1024 icon image with your design
2. Visit: https://www.appicon.co or https://appicon.build
3. Upload your 1024x1024 image
4. Download the generated icon set
5. Place the icons in: `Hedaya/Assets.xcassets/AppIcon.appiconset/`

### Method 2: Use Xcode's Icon Generator

1. Open `Hedaya.xcodeproj` in Xcode
2. Go to `Assets.xcassets` → `AppIcon`
3. Drag a 1024x1024 image into the App Store slot
4. Xcode will automatically generate all sizes

### Method 3: Manual Creation

If you have an image editor:

1. Create a 1024x1024 PNG image
2. Use the following sizes (all in pixels):
   - 40x40 (20pt @2x)
   - 60x60 (20pt @3x)
   - 58x58 (29pt @2x)
   - 87x87 (29pt @3x)
   - 80x80 (40pt @2x)
   - 120x120 (40pt @3x)
   - 120x120 (60pt @2x)
   - 180x180 (60pt @3x)
   - 76x76 (76pt @1x - iPad)
   - 152x152 (76pt @2x - iPad)
   - 167x167 (83.5pt @2x - iPad Pro)
   - 1024x1024 (App Store)

3. Name them according to the filenames in `Contents.json`
4. Place them in `Hedaya/Assets.xcassets/AppIcon.appiconset/`

## Icon Design Suggestions

For an Azkar app, consider:
- 🌙 **Crescent moon and star** (classic Islamic symbol)
- 📿 **Prayer beads (Tasbih)** in a circular arrangement
- 🕌 **Mosque silhouette** or minaret
- ✨ **Arabic calligraphy** of "هداية" or "الله"
- 🕋 **Kaaba** or geometric Islamic patterns

## Color Scheme

Recommended colors for Islamic apps:
- **Primary Green**: #1B7A4A (dark green)
- **Accent Green**: #2ECC71 (bright green)
- **Gold/White**: #FFFFFF or #F39C12 (for contrast)

## After Creating Icons

1. Make sure all icon files are in: `Hedaya/Assets.xcassets/AppIcon.appiconset/`
2. The `Contents.json` file should reference all icons correctly
3. Build the app in Xcode to see the icon
4. The icon will appear on the home screen when installed

## Testing the Icon

1. Build and run the app: `⌘R` in Xcode
2. Check the home screen on simulator/device
3. The icon should appear with your design

---

**Note**: The icon generator script (`generate-icon.py`) creates a simple but elegant icon automatically. For a custom design, use one of the alternative methods above.
