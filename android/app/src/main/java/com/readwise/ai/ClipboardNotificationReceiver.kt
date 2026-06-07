package com.readwise.ai

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ClipboardNotificationReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_USE_CLIPBOARD = "com.readwise.ai.USE_CLIPBOARD"
        const val ACTION_DISMISS = "com.readwise.ai.DISMISS_CLIPBOARD"
    }

    override fun onReceive(context: Context, intent: Intent?) {
        when (intent?.action) {
            ACTION_USE_CLIPBOARD -> {
                val text = intent.getStringExtra("clipboard_text")
                val mainIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("clipboard_text", text)
                    putExtra("source", "clipboard_notification")
                }
                context.startActivity(mainIntent)
            }
            ACTION_DISMISS -> {
                // Dismiss the notification - handled by notification manager
            }
        }
    }
}
