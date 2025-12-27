import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val hasReleaseKeystore = keystorePropertiesFile.exists() &&
    keystoreProperties.getProperty("keyAlias") != null &&
    keystoreProperties.getProperty("keyPassword") != null &&
    keystoreProperties.getProperty("storeFile") != null &&
    keystoreProperties.getProperty("storePassword") != null
android {
    namespace = "com.roknmuslim.roknmuslimapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // هذه السطور تمت إضافتها لتفعيل core library desugaring بصيغة Kotlin DSL
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.roknmuslim.roknmuslimapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties.getProperty("storeFile")?.let {
                    rootProject.file(it)
                }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            // signingConfig = signingConfigs.getByName("debug")
           signingConfig = if (hasReleaseKeystore) {
               signingConfigs.getByName("release")
           } else {
               signingConfigs.getByName("debug")
           }
        }
    }
}

flutter {
    source = "../.."
}

// هذه الكتلة تمت إضافتها لإضافة تبعية desugaring بصيغة Kotlin DSL
dependencies {
    // تم تحديث الإصدار هنا من 1.1.5 إلى 2.1.4
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // <--- هنا التغيير
}
