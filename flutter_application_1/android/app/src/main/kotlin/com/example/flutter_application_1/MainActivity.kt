package com.example.flutter_application_1

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File
import java.util.Properties

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_application_1/config"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getApiKey" -> {
                    try {
                        val properties = Properties()
                        val localPropertiesFile = File(context.applicationContext.filesDir.parentFile.parentFile, "local.properties")
                        if (localPropertiesFile.exists()) {
                            properties.load(localPropertiesFile.inputStream())
                            val apiKey = properties.getProperty("NINJA_API_KEY")
                            if (apiKey != null && apiKey.isNotEmpty()) {
                                result.success(apiKey)
                            } else {
                                result.error("NO_API_KEY", "API key not found in local.properties", null)
                            }
                        } else {
                            result.error("NO_FILE", "local.properties file not found", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", "Error reading API key: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
