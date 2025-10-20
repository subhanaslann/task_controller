package com.example.minitasktracker.di

import com.example.minitasktracker.BuildConfig
import com.example.minitasktracker.data.local.SessionManager
import com.example.minitasktracker.data.remote.api.AdminApi
import com.example.minitasktracker.data.remote.api.AuthApi
import com.example.minitasktracker.data.remote.api.TaskApi
import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import kotlinx.coroutines.runBlocking
import kotlinx.serialization.json.Json
import okhttp3.Interceptor
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import timber.log.Timber
import java.util.concurrent.TimeUnit
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
  fun provideAuthInterceptor(sessionManager: SessionManager): Interceptor {
    return Interceptor { chain ->
      val token = runBlocking { sessionManager.getToken() }
      val request = chain.request().newBuilder().apply {
        token?.let {
          addHeader("Authorization", "Bearer $it")
          Timber.d("Added auth token to request: ${chain.request().url}")
        }
      }.build()
      chain.proceed(request)
    }
  }

  @Provides
  @Singleton
  fun provideLoggingInterceptor(): HttpLoggingInterceptor {
    return HttpLoggingInterceptor { message ->
      Timber.tag("OkHttp").d(message)
    }.apply {
      level = if (BuildConfig.DEBUG) {
        HttpLoggingInterceptor.Level.BODY
      } else {
        HttpLoggingInterceptor.Level.NONE
      }
    }
  }

  @Provides
  @Singleton
  fun provideOkHttpClient(
    authInterceptor: Interceptor,
    loggingInterceptor: HttpLoggingInterceptor
  ): OkHttpClient {
    return OkHttpClient.Builder()
      .addInterceptor(authInterceptor)
      .addInterceptor(loggingInterceptor)
      .connectTimeout(30, TimeUnit.SECONDS)
      .readTimeout(30, TimeUnit.SECONDS)
      .writeTimeout(30, TimeUnit.SECONDS)
      .build()
  }

  @Provides
  @Singleton
  fun provideRetrofit(okHttpClient: OkHttpClient, json: Json): Retrofit {
    val contentType = "application/json".toMediaType()
    return Retrofit.Builder()
      .baseUrl(BuildConfig.BASE_URL)
      .client(okHttpClient)
      .addConverterFactory(json.asConverterFactory(contentType))
      .build()
  }

  @Provides
  @Singleton
  fun provideAuthApi(retrofit: Retrofit): AuthApi {
    return retrofit.create(AuthApi::class.java)
  }

  @Provides
  @Singleton
  fun provideTaskApi(retrofit: Retrofit): TaskApi {
    return retrofit.create(TaskApi::class.java)
  }

  @Provides
  @Singleton
  fun provideAdminApi(retrofit: Retrofit): AdminApi {
    return retrofit.create(AdminApi::class.java)
  }
}
