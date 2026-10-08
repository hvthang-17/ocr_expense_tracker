plugins {
    id("com.android.application")
    // NOTE: Áp dụng Flutter Gradle Plugin sau Android và Kotlin Gradle Plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ocr_expense_tracker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Đặt Application ID duy nhất của ứng dụng.
        applicationId = "com.example.ocr_expense_tracker"
        // NOTE: Có thể điều chỉnh các giá trị sau theo nhu cầu ứng dụng.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // NOTE: Dùng mã phiên bản từ pubspec.yaml.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Thêm cấu hình ký release riêng trước khi phát hành.
            // NOTE: Tạm ký bằng khóa debug để `flutter run --release` hoạt động.
            signingConfig = signingConfigs.getByName("debug")
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
