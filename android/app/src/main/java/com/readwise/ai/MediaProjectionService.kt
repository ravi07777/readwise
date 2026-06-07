package com.readwise.ai

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.DisplayMetrics
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

class MediaProjectionService : Service() {

    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var imageReader: ImageReader? = null
    private var mediaProjectionManager: MediaProjectionManager? = null
    private var resultCode: Int = 0
    private var resultData: Intent? = null
    private var isCapturing = false
    private val backgroundExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        var isCapturing = false
            private set
        private var instance: MediaProjectionService? = null
        private var screenshotCallback: ((ByteArray) -> Unit)? = null
        private var regionCallback: ((ByteArray) -> Unit)? = null

        const val NOTIFICATION_ID = 1002

        fun requestMediaProjection(activity: MainActivity, requestCode: Int) {
            val manager = activity.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            activity.startActivityForResult(manager.createScreenCaptureIntent(), requestCode)
        }

        fun startCapture(context: Context, resultCode: Int, data: Intent) {
            val intent = Intent(context, MediaProjectionService::class.java).apply {
                putExtra("result_code", resultCode)
                putExtra("result_data", data)
                putExtra("action", "start_capture")
            }
            ContextCompat.startForegroundService(context, intent)
        }

        fun stopCapture() {
            instance?.stopCaptureInternal()
        }

        fun captureScreenshot(callback: (ByteArray) -> Unit) {
            screenshotCallback = callback
            instance?.captureScreenInternal()
        }

        fun captureRegion(left: Int, top: Int, right: Int, bottom: Int, callback: (ByteArray) -> Unit) {
            regionCallback = callback
            instance?.captureRegionInternal(left, top, right, bottom)
        }
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.getStringExtra("action")) {
            "start_capture" -> {
                resultCode = intent.getIntExtra("result_code", 0)
                resultData = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra("result_data", Intent::class.java)
                } else {
                    intent.getParcelableExtra("result_data")
                }

                val notification = createNotification()
                startForeground(NOTIFICATION_ID, notification)
                startProjection()
            }
            "stop_capture" -> {
                stopCaptureInternal()
                stopSelf()
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        stopCaptureInternal()
        instance = null
        super.onDestroy()
    }

    private fun createNotification(): Notification {
        val stopIntent = Intent(this, MediaProjectionService::class.java).apply {
            action = "STOP_CAPTURE"
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 0, stopIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            else PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, ReadWiseApplication.CHANNEL_MEDIA_PROJECTION)
            .setContentTitle("ReadWise Screen Capture")
            .setContentText("Capturing screen for OCR")
            .setSmallIcon(android.R.drawable.ic_menu_camera)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Stop", stopPendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun startProjection() {
        mediaProjection = mediaProjectionManager?.getMediaProjection(resultCode, resultData!!)
        setUpVirtualDisplay()
    }

    private fun setUpVirtualDisplay() {
        val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val metrics = DisplayMetrics()
        windowManager.defaultDisplay.getRealMetrics(metrics)

        val density = metrics.densityDpi
        val width = metrics.widthPixels
        val height = metrics.heightPixels

        imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)

        virtualDisplay = mediaProjection?.createVirtualDisplay(
            "ReadWiseCapture",
            width, height, density,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            imageReader?.surface, null, null
        )

        isCapturing = true
        Companion.isCapturing = true
    }

    private fun captureScreenInternal() {
        if (!isCapturing || imageReader == null) return

        backgroundExecutor.execute {
            try {
                val image = imageReader?.acquireLatestImage() ?: return@execute
                val planes = image.planes
                val buffer = planes[0].buffer
                val pixelStride = planes[0].pixelStride
                val rowStride = planes[0].rowStride
                val rowPadding = rowStride - pixelStride * image.width

                val bitmap = Bitmap.createBitmap(
                    image.width + rowPadding / pixelStride,
                    image.height,
                    Bitmap.Config.ARGB_8888
                )
                bitmap.copyPixelsFromBuffer(buffer)
                image.close()

                // Crop to actual width
                val croppedBitmap = Bitmap.createBitmap(bitmap, 0, 0, image.width, image.height)
                val outputStream = ByteArrayOutputStream()
                croppedBitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                val byteArray = outputStream.toByteArray()

                mainHandler.post {
                    screenshotCallback?.invoke(byteArray)
                    screenshotCallback = null
                }

                croppedBitmap.recycle()
                bitmap.recycle()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun captureRegionInternal(left: Int, top: Int, right: Int, bottom: Int) {
        if (!isCapturing || imageReader == null) return

        backgroundExecutor.execute {
            try {
                val image = imageReader?.acquireLatestImage() ?: return@execute
                val planes = image.planes
                val buffer = planes[0].buffer
                val pixelStride = planes[0].pixelStride
                val rowStride = planes[0].rowStride
                val rowPadding = rowStride - pixelStride * image.width

                val bitmap = Bitmap.createBitmap(
                    image.width + rowPadding / pixelStride,
                    image.height,
                    Bitmap.Config.ARGB_8888
                )
                bitmap.copyPixelsFromBuffer(buffer)
                image.close()

                // Crop to region
                val croppedBitmap = Bitmap.createBitmap(
                    bitmap,
                    left.coerceAtLeast(0),
                    top.coerceAtLeast(0),
                    (right - left).coerceAtMost(bitmap.width - left.coerceAtLeast(0)),
                    (bottom - top).coerceAtMost(bitmap.height - top.coerceAtLeast(0))
                )
                val outputStream = ByteArrayOutputStream()
                croppedBitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                val byteArray = outputStream.toByteArray()

                mainHandler.post {
                    regionCallback?.invoke(byteArray)
                    regionCallback = null
                }

                croppedBitmap.recycle()
                bitmap.recycle()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun stopCaptureInternal() {
        virtualDisplay?.release()
        virtualDisplay = null
        imageReader?.close()
        imageReader = null
        mediaProjection?.stop()
        mediaProjection = null
        isCapturing = false
        Companion.isCapturing = false
    }
}
