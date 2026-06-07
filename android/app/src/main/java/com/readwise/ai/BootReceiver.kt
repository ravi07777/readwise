package com.readwise.ai

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.content.ContextCompat

class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            // Restore overlay service if it was active before reboot
            val prefs = context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
            val overlayEnabled = prefs.getBoolean("overlay_enabled", false)

            if (overlayEnabled) {
                val serviceIntent = Intent(context, OverlayService::class.java)
                ContextCompat.startForegroundService(context, serviceIntent)
            }
        }
    }
}
