plugins {
  id("com.android.application")
  id("org.jetbrains.kotlin.android")
  id("com.google.dagger.hilt.android")
  id("org.jetbrains.kotlin.plugin.serialization")
  id("com.google.devtools.ksp")
}

android {
  namespace = "com.example.minitasktracker"
  compileSdk = 34

  defaultConfig {
    applicationId = "com.example.minitasktracker"
    minSdk = 28
    targetSdk = 34
    versionCode = 1
    versionName = "1.0"

    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    vectorDrawables {
      useSupportLibrary = true
    }
  }

  signingConfigs {
    create("release") {
      storeFile = file("../release-key.jks")
      storePassword = "BURAYA-KEYSTORE-SIFRENIZ"
      keyAlias = "tasktracker"
      keyPassword = "BURAYA-KEY-SIFRENIZ"
    }
  }

  buildTypes {
    debug {
      isDebuggable = true
      applicationIdSuffix = ".debug"
      versionNameSuffix = "-debug"
      buildConfigField("String", "BASE_URL", "\"https://api.diplomam.net/\"")
    }
    release {
      isMinifyEnabled = true
      isShrinkResources = true
      // signingConfig = signingConfigs.getByName("release")
      proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro"
      )
      buildConfigField("String", "BASE_URL", "\"https://api.diplomam.net/\"")
    }
  }

  compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
  }

  kotlinOptions {
    jvmTarget = "17"
  }

  buildFeatures {
    compose = true
    buildConfig = true
  }

  composeOptions {
    kotlinCompilerExtensionVersion = "1.5.8"
  }

  packaging {
    resources {
      excludes += "/META-INF/{AL2.0,LGPL2.1}"
    }
  }
}

dependencies {
  // Core Android
  implementation("androidx.core:core-ktx:1.13.1")
  implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.4")
  implementation("androidx.activity:activity-compose:1.9.1")

  // Compose BOM
  val composeBom = platform("androidx.compose:compose-bom:2024.02.00")
  implementation(composeBom)
  implementation("androidx.compose.ui:ui")
  implementation("androidx.compose.ui:ui-graphics")
  implementation("androidx.compose.ui:ui-tooling-preview")
  implementation("androidx.compose.material3:material3")
  implementation("androidx.compose.material:material-icons-extended")

  // Navigation
  implementation("androidx.navigation:navigation-compose:2.7.7")
  
  // Pull to refresh
  implementation("androidx.compose.material:material")

  // Hilt
  implementation("com.google.dagger:hilt-android:2.51.1")
  ksp("com.google.dagger:hilt-android-compiler:2.51.1")
  implementation("androidx.hilt:hilt-navigation-compose:1.2.0")

  // Networking
  implementation("com.squareup.retrofit2:retrofit:2.11.0")
  implementation("com.squareup.okhttp3:okhttp:4.12.0")
  implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
  implementation("com.jakewharton.retrofit:retrofit2-kotlinx-serialization-converter:1.0.0")

  // Kotlinx Serialization
  implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")

  // DataStore
  implementation("androidx.datastore:datastore-preferences:1.1.1")

  // Timber
  implementation("com.jakewharton.timber:timber:5.0.1")

  // Testing
  testImplementation("junit:junit:4.13.2")
  testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.8.1")
  testImplementation("io.mockk:mockk:1.13.11")
  testImplementation("app.cash.turbine:turbine:1.1.0")
  
  androidTestImplementation("androidx.test.ext:junit:1.2.1")
  androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
  androidTestImplementation(composeBom)
  androidTestImplementation("androidx.compose.ui:ui-test-junit4")
  androidTestImplementation("io.mockk:mockk-android:1.13.11")
  
  debugImplementation("androidx.compose.ui:ui-tooling")
  debugImplementation("androidx.compose.ui:ui-test-manifest")
}
