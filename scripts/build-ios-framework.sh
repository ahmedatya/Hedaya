#!/bin/sh
# Builds the KMP shared framework for iOS. Run from repo root.
# Requires Java 17+ and Gradle (./gradlew).
set -e
cd "$(dirname "$0")/.."
./gradlew :shared:linkReleaseFrameworkIosArm64 :shared:linkReleaseFrameworkIosSimulatorArm64
echo "Frameworks built at:"
echo "  shared/build/bin/iosArm64/releaseFramework/shared.framework"
echo "  shared/build/bin/iosSimulatorArm64/releaseFramework/shared.framework"
