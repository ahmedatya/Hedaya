# Kotlin Multiplatform (KMP) and Android / iOS

This repo uses a **shared** Kotlin Multiplatform module for data and parsing. The iOS app can use the shared framework when built and linked; the Android app uses the shared module directly.

## Layout

- **`shared/`** – KMP module: models (`Zikr`, `AzkarGroup`), `parseGroups()`, constants. Targets: Android, `iosArm64`, `iosSimulatorArm64`.
- **`Hedaya/`** – iOS app (Xcode). Uses `SharedAzkarLoader`, which calls the shared framework when linked, otherwise falls back to Swift `DataLoader`.
- **`android/`** – Android app (Compose). Depends on `shared`, loads JSON from assets (copied from `Hedaya/Data` at build time).

## Building

### Prerequisites

- **Java 17+** and **Gradle** (or use the project’s `./gradlew`).
- For Android: **Android SDK** (Android Studio or command-line).
- For iOS framework: **Xcode** (to link the framework; building the framework itself is done by Gradle).

### Android

From the repo root:

```bash
./gradlew :android:assembleDebug
```

The app will copy `Hedaya/Data` into `android/src/main/assets/data` before merge (see `copyDataToAssets` in `android/build.gradle.kts`). Output: `android/build/outputs/apk/debug/android-debug.apk`.

### Shared module (for both platforms)

```bash
./gradlew :shared:compileDebugKotlinAndroid   # Android
./gradlew :shared:linkReleaseFrameworkIosArm64           # Device
./gradlew :shared:linkReleaseFrameworkIosSimulatorArm64  # Simulator
```

### iOS app using the shared framework

1. Build the framework (requires Java/Gradle):

   ```bash
   ./scripts/build-ios-framework.sh
   ```

2. In Xcode, add the framework to the Hedaya target:
   - **Frameworks, Libraries, and Embedded Content**: add `shared/build/bin/iosArm64/releaseFramework/shared.framework` (and/or the simulator path for simulator builds).
   - **Framework Search Paths**: e.g. `$(SRCROOT)/../shared/build/bin/iosArm64/releaseFramework` (and the simulator path when building for simulator).

3. Build and run the iOS app. `SharedAzkarLoader` will use `shared` and call `parseGroups` from the framework.

If the framework is not linked, the iOS app still builds and runs using the Swift `DataLoader` (no `import shared`).

## Data

- **Single source of truth**: `Hedaya/Data/` (`groups.json` and `azkar/*.json`).
- **iOS**: Files are in the app bundle; `DataLoader` or the shared framework reads them.
- **Android**: Gradle copies `Hedaya/Data` into `android/src/main/assets/data`; the app reads from assets and calls `hedaya.shared.parseGroups()`.
