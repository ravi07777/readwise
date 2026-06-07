package com.readwise.ai

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Rect
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.view.View
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class PlatformChannels(private val context: Context) {

    companion object {
        const val CHANNEL_OCR = "com.readwise.ai/ocr"
        const val CHANNEL_SCREEN = "com.readwise.ai/screen"
        const val CHANNEL_CLIPBOARD_NATIVE = "com.readwise.ai/clipboard_native"
        const val CHANNEL_PLATFORM = "com.readwise.ai/platform"
    }

    fun registerAll(flutterEngine: FlutterEngine) {
        registerOcrChannel(flutterEngine)
        registerScreenChannel(flutterEngine)
        registerClipboardChannel(flutterEngine)
        registerPlatformChannel(flutterEngine)
    }

    private fun registerOcrChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_OCR)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "performOcr" -> {
                        val path = call.argument<String>("imagePath")
                        if (path != null) {
                            val file = File(path)
                            if (file.exists()) {
                                val bytes = file.readBytes()
                                // OCR will be performed via Flutter with ML Kit plugin
                                result.success(bytes.toList())
                            } else {
                                result.error("FILE_NOT_FOUND", "Image file not found", null)
                            }
                        } else {
                            result.error("NO_PATH", "No image path provided", null)
                        }
                    }
                    "hasOcrSupport" -> {
                        result.success(true) // ML Kit is available
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun registerScreenChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_SCREEN)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getScreenDimensions" -> {
                        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
                        val display = windowManager.defaultDisplay
                        val metrics = android.util.DisplayMetrics()
                        display.getRealMetrics(metrics)
                        result.success(mapOf(
                            "width" to metrics.widthPixels,
                            "height" to metrics.heightPixels,
                            "density" to metrics.density
                        ))
                    }
                    "saveToGallery" -> {
                        val path = call.argument<String>("path") ?: ""
                        val file = File(path)
                        if (file.exists()) {
                            val uri = Uri.fromFile(file)
                            // Add to gallery via media scanner
                            val intent = android.content.Intent(
                                android.content.Intent.ACTION_MEDIA_SCANNER_SCAN_FILE,
                                uri
                            )
                            context.sendBroadcast(intent)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun registerClipboardChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_CLIPBOARD_NATIVE)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getClipboardText" -> {
                        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        val clipData = clipboard.primaryClip
                        val text = if (clipData != null && clipData.itemCount > 0) {
                            clipData.getItemAt(0).text?.toString()
                        } else null
                        result.success(text)
                    }
                    "setClipboardText" -> {
                        val text = call.argument<String>("text") ?: ""
                        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        val clipData = ClipData.newPlainText("ReadWise", text)
                        clipboard.setPrimaryClip(clipData)
                        result.success(true)
                    }
                    "hasClipboardText" -> {
                        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        val clipData = clipboard.primaryClip
                        val hasText = clipData != null && clipData.itemCount > 0 &&
                                clipData.getItemAt(0).text != null
                        result.success(hasText)
                    }
                    "startMonitoring" -> {
                        // Clipboard monitoring is handled via ClipboardManager.OnPrimaryClipChangedListener
                        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        clipboard.addPrimaryClipChangedListener {
                            // Notify Flutter about clipboard change
                            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_CLIPBOARD_NATIVE)
                                .invokeMethod("onClipboardChanged", null)
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun registerPlatformChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_PLATFORM)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPlatformVersion" -> {
                        result.success("Android ${Build.VERSION.RELEASE}")
                    }
                    "getDeviceInfo" -> {
                        result.success(mapOf(
                            "model" to Build.MODEL,
                            "manufacturer" to Build.MANUFACTURER,
                            "sdkInt" to Build.VERSION.SDK_INT,
                            "release" to Build.VERSION.RELEASE
                        ))
                    }
                    "hasOverlayPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            result.success(
                                android.provider.Settings.canDrawOverlays(context)
                            )
                        } else {
                            result.success(true)
                        }
                    }
                    "requestOverlayPermission" -> {
                        // Should be handled in MainActivity
                        result.success(false)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
