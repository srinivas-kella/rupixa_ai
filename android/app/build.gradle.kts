plugins {
    id("com.android.application")

    id("com.google.gms.google-services")

    id("dev.flutter.flutter-gradle-plugin")
}

android {

    namespace = "com.rupixa.ai"

    compileSdk = flutter.compileSdkVersion

    ndkVersion = flutter.ndkVersion

    buildFeatures {
    buildConfig = true
}

    compileOptions {

        sourceCompatibility =
            JavaVersion.VERSION_17

        targetCompatibility =
            JavaVersion.VERSION_17

        isCoreLibraryDesugaringEnabled =
            true
    }

    defaultConfig {

        applicationId =
            "com.rupixa.ai"

        minSdk = flutter.minSdkVersion

        targetSdk =
            flutter.targetSdkVersion

        versionCode =
            flutter.versionCode

        versionName =
            flutter.versionName
    }

    buildTypes {

        release {

            signingConfig =
                signingConfigs.getByName(
                    "debug"
                )
        }
    }
}

kotlin {

    compilerOptions {

        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl
                .JvmTarget.JVM_17
    }
}

dependencies {

    implementation(
        "org.jetbrains.kotlin:kotlin-stdlib:2.2.20"
    )

    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.2"
    )
}

flutter {
    source = "../.."
}
