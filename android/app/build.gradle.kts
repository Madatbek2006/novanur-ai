import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "uz.nova.ai"
    compileSdk = 36
    // ndkVersion = flutter.ndkVersion
    ndkVersion = "28.2.13676358"
    configurations {
        all {
            exclude(group = "com.google.firebase", module = "firebase-iid")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "uz.nova.ai"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")

            // R8 для релиза включён и так, но ресурсы он не трогает, пока
            // об этом не попросишь явно.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
    applicationVariants.all {
        val variant = this
        variant.outputs.all {
            val output = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            val buildTypeName = variant.buildType.name
            val versionName = variant.versionName

            // Имя обязано включать архитектуру. Без этого сборка с
            // --split-per-abi пишет все варианты в один файл, задачи упаковки
            // дерутся за него и сборка падает с "Failed to create ...apk".
            val abi = output.filters
                .firstOrNull { it.filterType == "ABI" }
                ?.identifier
                ?.let { "-$it" }
                .orEmpty()

            if (output.outputFile.name.endsWith(".apk")) {
                output.outputFileName = "NurNova AI $buildTypeName-$versionName$abi.apk"
            } else if (output.outputFile.name.endsWith(".aab")) {
                output.outputFileName = "NurNova AI $buildTypeName-$versionName.aab"
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.firebase:firebase-messaging:23.4.1")
    // Только латиница: приложение просит TextRecognitionScript.latin и
    // никогда ничего другого (scan_text_page.dart). Пакеты китайского,
    // японского, корейского и деванагари лежали мёртвым грузом.
    implementation("com.google.mlkit:text-recognition:16.0.0")
    implementation("androidx.core:core:1.12.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}