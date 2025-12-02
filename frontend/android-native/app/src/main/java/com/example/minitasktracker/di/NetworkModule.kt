package com.example.minitasktracker.di

import com.example.minitasktracker.data.remote.FirebaseService
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import kotlinx.serialization.json.Json
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

  @Provides
  @Singleton
  fun provideJson(): Json = Json {
    ignoreUnknownKeys = true
    isLenient = true
    encodeDefaults = false
  }

  @Provides
  @Singleton
  fun provideFirebaseService(): FirebaseService {
    return FirebaseService()
  }
}
