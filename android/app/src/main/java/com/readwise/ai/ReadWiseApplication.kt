package com.readwise.ai

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

class ReadWiseApplication : Application() {

    companion object {
        const val CHANNEL_OVERLAY = "readwise_overlay"
        const val CHANNEL_MEDIA_PROJECTION = "readwise_media_projection"
        const val CHANNEL_CLIPBOARD = "readwise_clipboard"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)

            val overlayChannel = NotificationChannel(
                CHANNEL_OVERLAY,
                getString(R.string.overlay_channel_name),
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = getString(R.string.overlay_channel_description)
                setShowBadge(false)
            }

            val mediaProjectionChannel = NotificationChannel(
                CHANNEL_MEDIA_PROJECTION,
                getString(R.string.media_projection_channel_name),
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = getString(R.string.media_projection_channel_description)
                setShowBadge(false)
            }

            val clipboardChannel = NotificationChannel(
                CHANNEL_CLIPBOARD,
                getString(R.string.clipboard_channel_name),
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = getString(R.string.clipboard_channel_description)
                setShowBadge(false)
            }

            notificationManager.createNotificationChannel(overlayChannel)
            notificationManager.createNotificationChannel(mediaProjectionChannel)
            notificationManager.createNotificationChannel(clipboardChannel)
        }
    }
}
