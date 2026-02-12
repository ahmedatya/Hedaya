// Require Gradle 8.x (Kotlin/AGP not yet compatible with Gradle 9)
if (gradle.gradleVersion.startsWith("9.")) {
    throw GradleException(
        "This project requires Gradle 8.x. You have ${gradle.gradleVersion}. " +
        "Download 8.11.1 from https://gradle.org/releases/ (extract and add bin/ to PATH), or use SDKMAN: sdk install gradle 8.11.1"
    )
}

plugins {
    kotlin("multiplatform") version "2.0.21" apply false
    kotlin("android") version "2.0.21" apply false
    kotlin("plugin.compose") version "2.0.21" apply false
    id("com.android.application") version "8.7.2" apply false
    id("com.android.library") version "8.7.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
