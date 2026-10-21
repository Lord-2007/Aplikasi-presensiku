plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.presensiku"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.presensiku"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storePass = System.getenv("KEYSTORE_PASSWORD") ?: ""
            val keyAliasVal = System.getenv("KEY_ALIAS") ?: System.getenv("KLY_ALIAS") ?: ""
            val keyPass = System.getenv("KEY_PASSWORD") ?: storePass

            val keystoreFile = file("upload.jks")
            val altKeystoreFile = rootProject.file("upload.jks")
            val keystoreParent = rootProject.file("../upload.jks")
            val targetKeystore = when {
                keystoreFile.exists() -> keystoreFile
                altKeystoreFile.exists() -> altKeystoreFile
                keystoreParent.exists() -> keystoreParent
                else -> null
            }

            if (targetKeystore != null && storePass.isNotEmpty() && keyAliasVal.isNotEmpty()) {
                storeFile = targetKeystore
                storePassword = storePass
                keyAlias = keyAliasVal
                keyPassword = keyPass
            }
        }
    }

    buildTypes {
        release {
            val releaseSigning = signingConfigs.findByName("release")
            if (releaseSigning?.storeFile != null) {
                signingConfig = releaseSigning
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
