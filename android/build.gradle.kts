group = "com.vendor.fuelmetrix_miniapp"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.2.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // The vendor's private Maven repo (simulated here as a local
        // directory bundled inside this package, so fuelmetrix_miniapp is
        // self-contained on pub.dev) — this is how mini_native_lib's own
        // transitive dependencies (CameraX, etc) resolve automatically.
        maven { url = uri("${project.projectDir}/maven-repo") }
    }
}

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "com.vendor.fuelmetrix_miniapp"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

dependencies {
    // The vendor's mini app SDK, resolved from their Maven repo — a
    // compiled .aar only, no .kt source. Its own dependencies (CameraX,
    // etc) resolve automatically via its POM, same as any Maven artifact.
    implementation("com.vendor:mininativelib:1.0.4")
}
