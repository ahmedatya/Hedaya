# Hedaya Android APK — Install Package

This folder holds the **pre-built Android APK** for Hedaya so users can install the app without building from source.

## For users: install the app

1. **Get the APK**
   - Download **`hedaya-debug.apk`** from this folder (e.g. from the [GitHub repo](https://github.com/ahmedatya/Hedaya) → `releases/`).
   - Or clone the repo and open the `releases/` folder; the APK file(s) will be here when published.

2. **Install on your Android device**
   - Copy the APK to your phone (USB, cloud, or download on device).
   - Open the APK file. If prompted, allow installation from “Unknown sources” (or “Install unknown apps” for that app).
   - Tap **Install** and open **هداية (Hedaya)** when done.

**Requirements:** Android 7.0 (API 24) or higher.

## For maintainers: adding a new APK

To publish a new installable package:

1. **Build a release APK** (from the repo root):
   ```bash
   ./gradlew :android:assembleRelease
   ```
   Output: `android/build/outputs/apk/release/android-release-unsigned.apk`  
   (If you use signing, the signed APK may have a different name in the same directory.)

2. **Copy the APK here** with a clear name, e.g.:
   ```bash
   cp android/build/outputs/apk/release/android-release-unsigned.apk releases/hedaya-release.apk
   ```
   Or use a versioned name: `hedaya-1.0.apk`.

3. **Commit and push** so the APK is available in the repo:
   ```bash
   git add releases/hedaya-release.apk
   git commit -m "Add release APK for install"
   git push
   ```

Optional: you can also publish the same APK as a [GitHub Release](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository) and link to it from this README for easier downloading.
