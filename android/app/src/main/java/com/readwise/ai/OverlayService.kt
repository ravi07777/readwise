package com.readwise.ai

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.*
import android.widget.ImageView
import androidx.core.app.NotificationCompat

class OverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var isDragging = false
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f
    private var isExpanded = false
    private var expandedView: View? = null

    companion object {
        var isRunning = false
            private set
        const val NOTIFICATION_ID = 1001
    }

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (isRunning) {
            return START_STICKY
        }

        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)
        showOverlayButton()
        isRunning = true
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        dismissOverlay()
        isRunning = false
        super.onDestroy()
    }

    private fun createNotification(): Notification {
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openPendingIntent = PendingIntent.getActivity(
            this, 0, openIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            else PendingIntent.FLAG_UPDATE_CURRENT
        )

        val closeIntent = Intent(this, OverlayService::class.java).apply {
            action = "STOP_OVERLAY"
        }
        val closePendingIntent = PendingIntent.getService(
            this, 1, closeIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            else PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, ReadWiseApplication.CHANNEL_OVERLAY)
            .setContentTitle("ReadWise AI Assistant")
            .setContentText("Floating assistant is active")
            .setSmallIcon(android.R.drawable.ic_menu_edit)
            .setContentIntent(openPendingIntent)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Stop", closePendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun showOverlayButton() {
        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        overlayView = inflater.inflate(R.layout.overlay_button, null)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        )

        val prefs = getSharedPreferences("overlay_prefs", MODE_PRIVATE)
        params.x = prefs.getFloat("position_x", 0f).toInt()
        params.y = prefs.getFloat("position_y", 300f).toInt()

        params.gravity = Gravity.TOP or Gravity.START

        val floatingButton = overlayView?.findViewById<ImageView>(R.id.floating_button)
        floatingButton?.setOnTouchListener { _, event ->
            val paramsUpdate = params
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    isDragging = false
                    initialX = paramsUpdate.x
                    initialY = paramsUpdate.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val deltaX = (event.rawX - initialTouchX).toInt()
                    val deltaY = (event.rawY - initialTouchY).toInt()
                    if (Math.abs(deltaX) > 5 || Math.abs(deltaY) > 5) {
                        isDragging = true
                        paramsUpdate.x = initialX + deltaX
                        paramsUpdate.y = initialY + deltaY
                        windowManager?.updateViewLayout(overlayView, paramsUpdate)
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (!isDragging) {
                        showQuickMenu()
                    } else {
                        snapToEdge(paramsUpdate)
                    }
                    isDragging = false
                    true
                }
                else -> false
            }
        }

        floatingButton?.setOnLongClickListener {
            showExpandedMenu()
            true
        }

        try {
            windowManager?.addView(overlayView, params)
        } catch (e: Exception) {
            stopSelf()
        }
    }

    private fun snapToEdge(params: WindowManager.LayoutParams) {
        val display = windowManager?.defaultDisplay
        val point = android.graphics.Point()
        display?.getSize(point)
        val screenWidth = point.x

        val halfButtonWidth = 48 // approximate half width of button
        val snappedX: Int
        if (params.x + halfButtonWidth > screenWidth / 2) {
            snappedX = screenWidth - halfButtonWidth * 2
        } else {
            snappedX = 0
        }

        params.x = snappedX
        windowManager?.updateViewLayout(overlayView, params)

        val prefs = getSharedPreferences("overlay_prefs", MODE_PRIVATE)
        prefs.edit()
            .putFloat("position_x", snappedX.toFloat())
            .putFloat("position_y", params.y.toFloat())
            .apply()
    }

    private fun showQuickMenu() {
        if (isExpanded) {
            dismissExpandedView()
            return
        }

        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        expandedView = inflater.inflate(R.layout.overlay_quick_menu, null)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )

        params.gravity = Gravity.CENTER
        isExpanded = true

        try {
            windowManager?.addView(expandedView, params)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun showExpandedMenu() {
        // Long press shows full action menu via Flutter
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("show_quick_menu", true)
        }
        startActivity(intent)
    }

    private fun dismissExpandedView() {
        expandedView?.let {
            try {
                windowManager?.removeView(it)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        expandedView = null
        isExpanded = false
    }

    private fun dismissOverlay() {
        dismissExpandedView()
        overlayView?.let {
            try {
                windowManager?.removeView(it)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        overlayView = null
    }
}
