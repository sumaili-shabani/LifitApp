plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lifti_app"
    compileSdk = 35
    ndkVersion = "29.0.13113456"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.lifti_app"
        minSdk = flutter.minSdkVersion.toInt()
        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    // 🔐 Ajout de la config de signature "debug"
    signingConfigs {
        getByName("debug") {
            // Optionnel : tu peux personnaliser ici si tu veux
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")  // Syntaxe Kotlin DSL
    implementation("androidx.window:window:1.0.0")  // Syntaxe Kotlin DSL
    implementation("com.stripe:stripe-android:20.52.0")
    implementation("com.pusher:pusher-java-client:2.2.6") // <- version stable

}

flutter {
    source = "../.."
}