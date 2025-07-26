package com.example.travelcompanion

import android.app.Application

import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
  override fun onCreate() {
    super.onCreate()
    MapKitFactory.setApiKey("ffbde21e-cc1d-4116-b754-24a968d7d2fa") 
  }
}