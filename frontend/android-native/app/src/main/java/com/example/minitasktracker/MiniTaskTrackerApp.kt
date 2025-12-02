package com.example.minitasktracker

import android.app.Application
import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber

@HiltAndroidApp
class MiniTaskTrackerApp : Application() {

  override fun onCreate() {
    super.onCreate()
    
    if (BuildConfig.DEBUG) {
      Timber.plant(Timber.DebugTree())
    }
    
    Timber.d("MiniTaskTracker App initialized")
  }
}
