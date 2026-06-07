package com.readwise.ai

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL_OVERLAY = "com.readwise.ai/overlay"
        const val CHANNEL_ACCESSIBILITY = "com.readwise.ai/accessibility"
        const val CHANNEL_SHARE = "com.readwise.ai/share"
        const val CHANNEL_SCREENSHOT = "com.readwise.ai/screenshot"
        const val CHANNEL_CLIPBOARD = "com.readwise.ai/clipboard"
        const val REQUEST_CODE_OVERLAY = 1001
        const val REQUEST_CODE_MEDIA_PROJECTION = 1002
    }

    private var sharedText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleSharedIntent(intent)
        setupPlatformChannels()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleSharedIntent(intent)
    }

    private fun handleSharedIntent(intent: Intent) {
        if (intent.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
        }
    }

    private fun setupPlatformChannels() {
        // Overlay channel
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL_OVERLAY)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startOverlay" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            if (Settings.canDrawOverlays(this)) {
                                val intent = Intent(this, OverlayService::class.java)
                                ContextCompat.startForegroundService(this, intent)
                                result.success(true)
                            } else {
                                val intent = Intent(
                                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                    android.net.Uri.parse("package:$packageName")
                                )
                                startActivityForResult(intent, REQUEST_CODE_OVERLAY)
                                result.success(false)
                            }
                        } else {
                            val intent = Intent(this, OverlayService::class.java)
                            ContextCompat.startForegroundService(this, intent)
                            result.success(true)
                        }
                    }
                    "stopOverlay" -> {
                        val intent = Intent(this, OverlayService::class.java)
                        stopService(intent)
                        result.success(true)
                    }
                    "isOverlayRunning" -> {
                        result.success(OverlayService.isRunning)
                    }
                    "getOverlayPosition" -> {
                        val prefs = getSharedPreferences("overlay_prefs", MODE_PRIVATE)
                        val x = prefs.getFloat("position_x", 0f)
                        val y = prefs.getFloat("position_y", 300f)
                        result.success(mapOf("x" to x, "y" to y))
                    }
                    "updateOverlayPosition" -> {
                        val x = call.argument<Double>("x")?.toFloat() ?: 0f
                        val y = call.argument<Double>("y")?.toFloat() ?: 0f
                        val prefs = getSharedPreferences("overlay_prefs", MODE_PRIVATE)
                        prefs.edit().putFloat("position_x", x).putFloat("position_y", y).apply()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        // Accessibility channel
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL_ACCESSIBILITY)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isAccessibilityEnabled" -> {
                        val enabled = ReadWiseAccessibilityService.isRunning
                        result.success(enabled)
                    }
                    "openAccessibilitySettings" -> {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    }
                    "getSelectedText" -> {
                        val text = ReadWiseAccessibilityService.selectedText
                        result.success(text)
                    }
                    else -> result.notImplemented()
                }
            }

        // Share channel
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL_SHARE)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSharedText" -> {
                        result.success(sharedText)
                        sharedText = null
                    }
                    else -> result.notImplemented()
                }
            }

        // Screenshot channel
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL_SCREENSHOT)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startScreenCapture" -> {
                        MediaProjectionService.requestMediaProjection(this, REQUEST_CODE_MEDIA_PROJECTION)
                        result.success(true)
                    }
                    "isCapturing" -> {
                        result.success(MediaProjectionService.isCapturing)
                    }
                    "stopScreenCapture" -> {
                        MediaProjectionService.stopCapture()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            REQUEST_CODE_OVERLAY -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    if (Settings.canDrawOverlays(this)) {
                        val intent = Intent(this, OverlayService::class.java)
                        ContextCompat.startForegroundService(this, intent)
                    }
                }
            }
            REQUEST_CODE_MEDIA_PROJECTION -> {
                if (resultCode == RESULT_OK && data != null) {
                    MediaProjectionService.startCapture(this, resultCode, data)
                }
            }
        }
    }
}
