# Testing the Android app

## Quick test (script)

From the repo root:

```bash
./scripts/test-android.sh
```

The script will:

1. Find Java 17+ (JAVA_HOME or IntelliJ/Android Studio JBR).
2. Find the Android SDK (ANDROID_HOME or `local.properties`).
3. Use `./gradlew` or `gradle` to build the debug APK.
4. Copy `Hedaya/Data` into `android/src/main/assets/data` if needed.
5. If a device or emulator is attached: install the APK and launch the app.

If no device/emulator is connected, it only builds; start an AVD (or connect a device) and run the script again to install and launch.

You can pass extra Gradle options, e.g. `./scripts/test-android.sh --no-daemon`.

**Gradle version:** This project requires **Gradle 8.x**. Gradle 9.x is not yet compatible. If you use system `gradle` (e.g. from Homebrew), it may be 9.x—use [Gradle 8.11.1](https://gradle.org/releases/) (extract and add `bin/` to PATH) or SDKMAN: `sdk install gradle 8.11.1`.

**If you see `NoClassDefFoundError` with `./gradlew`:** the wrapper jar may be incomplete. Use Gradle 8.11.1 from the link above.

## Prerequisites

1. **Java 17+** (e.g. from IntelliJ IDEA: `export JAVA_HOME="/Applications/IntelliJ IDEA.app/Contents/jbr/Contents/Home"`, or install [Eclipse Temurin](https://adoptium.net/)).
2. **Android SDK** (install via [Android Studio](https://developer.android.com/studio) or command-line tools).
3. **Gradle**: use the project’s Gradle (see below) or install Gradle 8.x and run from the repo root.

## Set Android SDK

Create or edit `local.properties` in the repo root:

```properties
sdk.dir=/path/to/your/Android/sdk
```

Typical path with Android Studio on macOS: `~/Library/Android/sdk`.

## Build with project Gradle (wrapper)

If `./gradlew` works (Java 17+ and a valid Gradle wrapper):

```bash
export JAVA_HOME="/path/to/jdk17"   # optional if java is on PATH
./gradlew :android:assembleDebug
```

APK output: `android/build/outputs/apk/debug/android-debug.apk`.

## Build with full Gradle 8.x

If the wrapper fails (missing `gradle-wrapper.jar`), use a full Gradle 8.11+ installation:

```bash
export JAVA_HOME="/path/to/jdk17"
/path/to/gradle-8.11.1/bin/gradle :android:assembleDebug
```

## Run on device or emulator

1. Enable USB debugging on a physical device, or start an AVD from Android Studio.
2. Install and run:
   ```bash
   ./gradlew :android:installDebug
   ```
   or install the APK manually:
   ```bash
   adb install android/build/outputs/apk/debug/android-debug.apk
   adb shell am start -n com.hedaya.android/.MainActivity
   ```

## Data

The build copies `Hedaya/Data` into the app’s assets (`copyDataToAssets` task). Groups and azkar load from the shared KMP module; the app shows the same content as iOS.
