android {
    namespace = "com.example.tolab"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = "27.0.12077973" ← احذفها لو مش محتاج NDK

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.tolab"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled true // ✅ دعم multiDex
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")

            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
