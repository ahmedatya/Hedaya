# Testing the Android app

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
