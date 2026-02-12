#!/bin/sh
# Test the Android version of Hedaya: build, install, and optionally launch on emulator or device.
# Run from repo root: ./scripts/test-android.sh
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# --- Find Java 17+ ---
find_java() {
    if [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
        "$JAVA_HOME/bin/java" -version 2>&1 | grep -q "version \"1[7-9]\|\"2[0-9]" && echo "$JAVA_HOME" && return
    fi
    for candidate in \
        "/Applications/IntelliJ IDEA.app/Contents/jbr/Contents/Home" \
        "/Applications/Android Studio.app/Contents/jbr/Contents/Home" \
        "/Applications/Android Studio.app/Contents/jre/Contents/Home" \
        "$HOME/Library/Java/JavaVirtualMachines/"*"/Contents/Home"; do
        [ -x "$candidate/bin/java" ] 2>/dev/null || continue
        "$candidate/bin/java" -version 2>&1 | grep -q "version \"1[7-9]\|\"2[0-9]" && echo "$candidate" && return
    done
    return 1
}

echo "=== Hedaya Android test ==="
JAVA_HOME="${JAVA_HOME:-$(find_java)}"
if [ -z "$JAVA_HOME" ]; then
    echo "Error: Java 17+ not found. Set JAVA_HOME or install JDK 17+."
    exit 1
fi
export JAVA_HOME
echo "Using JAVA_HOME=$JAVA_HOME"

# --- Android SDK ---
if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
    for d in "$HOME/Library/Android/sdk" "/Users/$(whoami)/Library/Android/sdk"; do
        [ -d "$d/platform-tools" ] && export ANDROID_HOME="$d" && break
    done
fi
[ -n "$ANDROID_HOME" ] && export ANDROID_SDK_ROOT="$ANDROID_HOME"

if [ ! -d "${ANDROID_HOME:-x}/platform-tools" ]; then
    if [ -f "$REPO_ROOT/local.properties" ]; then
        SDK_DIR=$(grep '^sdk.dir=' "$REPO_ROOT/local.properties" | cut -d= -f2- | tr -d '\r')
        [ -n "$SDK_DIR" ] && [ -d "$SDK_DIR/platform-tools" ] && export ANDROID_HOME="$SDK_DIR" && export ANDROID_SDK_ROOT="$SDK_DIR"
    fi
fi

if [ ! -d "${ANDROID_HOME:-x}/platform-tools" ]; then
    echo "Error: Android SDK not found. Set ANDROID_HOME or create local.properties with sdk.dir=..."
    exit 1
fi
echo "Using ANDROID_HOME=$ANDROID_HOME"

# --- Gradle: need 8.x (9.x breaks this project). Prefer wrapper, then system gradle 8.x ---
GRADLE_CMD=""
GRADLE_ARGS="-p $REPO_ROOT"
if [ -x "$REPO_ROOT/gradlew" ]; then
    if (cd "$REPO_ROOT" && "$REPO_ROOT/gradlew" --version >/dev/null 2>&1); then
        GRADLE_CMD="$REPO_ROOT/gradlew"
        GRADLE_ARGS=""
    fi
fi
if [ -z "$GRADLE_CMD" ] && command -v gradle >/dev/null 2>&1; then
    GRADLE_VER=$(gradle --version 2>/dev/null | grep "Gradle" | head -1 | sed -n 's/.*Gradle \([0-9]*\).*/\1/p')
    if [ "$GRADLE_VER" = "9" ]; then
        echo "Error: This project requires Gradle 8.x. Your 'gradle' is 9.x."
        echo "Use Gradle 8.11.1: https://gradle.org/releases/ (extract and add bin/ to PATH)"
        echo "Or: sdk install gradle 8.11.1   (if using SDKMAN)"
        exit 1
    fi
    GRADLE_CMD="gradle"
fi
if [ -z "$GRADLE_CMD" ]; then
    if [ -x "$REPO_ROOT/gradlew" ]; then
        echo "Error: ./gradlew failed (wrapper jar may be incomplete). Use Gradle 8.11.1:"
        echo "  https://gradle.org/releases/  (extract and add bin/ to PATH)"
        exit 1
    fi
    echo "Error: No working Gradle 8.x. Use ./gradlew (fix wrapper) or install Gradle 8.11.1."
    exit 1
fi
echo "Using Gradle: $GRADLE_CMD"

# --- Copy data into assets (idempotent) ---
DATA_SRC="$REPO_ROOT/Hedaya/Data"
DATA_DST="$REPO_ROOT/android/src/main/assets/data"
if [ ! -f "$DATA_DST/groups.json" ]; then
    echo "Copying Hedaya/Data into android assets..."
    mkdir -p "$DATA_DST"
    cp -R "$DATA_SRC/"* "$DATA_DST/"
fi

# --- Build ---
echo ""
echo "Building debug APK..."
if [ "$GRADLE_CMD" = "$REPO_ROOT/gradlew" ]; then
    "$GRADLE_CMD" :android:assembleDebug "$@"
else
    $GRADLE_CMD $GRADLE_ARGS :android:assembleDebug "$@"
fi

APK="$REPO_ROOT/android/build/outputs/apk/debug/android-debug.apk"
if [ ! -f "$APK" ]; then
    echo "Error: APK not produced at $APK"
    exit 1
fi
echo "APK: $APK"

# --- Device or emulator ---
ADB="${ANDROID_HOME}/platform-tools/adb"
"$ADB" start-server 2>/dev/null || true
DEVICES=$("$ADB" devices -l | grep -v "List of devices" | grep -w "device" || true)
if [ -z "$DEVICES" ]; then
    echo ""
    echo "No device or emulator attached. Install the APK manually:"
    echo "  adb install $APK"
    echo "Or start an AVD from Android Studio (Device Manager) and run this script again."
    exit 0
fi

echo ""
echo "Installing on device/emulator..."
"$ADB" install -r "$APK"
echo "Launching Hedaya..."
"$ADB" shell am start -n com.hedaya.android/.MainActivity

echo ""
echo "Done. Hedaya (Android) should be running on the device."
