plugins {
    id("com.android.application")
    id("com.google.gms.google-services") 
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tolab" // ✅ هذا هو السطر المهم
    compileSdk = 35
    //ndkVersion = "27.0.12077973"

   defaultConfig {
    applicationId = "com.example.tolab"
    minSdk = 23        // >>> يجب تغييره من 21 إلى 23 على الأقل
    targetSdk = 35
    versionCode = 1
    versionName = "1.0"
    ndkVersion = "27.0.12077973"
    }


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ صححنا هذا السطر
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // ✅ صححنا هذا السطر
}


flutter {
    source = "../.."
}
