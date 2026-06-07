package com.readwise.ai

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class ReadWiseAccessibilityService : AccessibilityService() {

    companion object {
        var isRunning = false
            private set
        var selectedText: String? = null
            private set
        var lastFocusedPackage: String? = null
            private set
        var lastFocusedClass: String? = null
            private set
        var lastEventType: Int = -1
            private set
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        isRunning = true
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return

        lastEventType = event.eventType

        when (event.eventType) {
            AccessibilityEvent.TYPE_VIEW_TEXT_SELECTION_CHANGED -> {
                extractSelectedText(event)
            }
            AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED -> {
                // Monitor text changes for clipboard-like functionality
            }
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                lastFocusedPackage = event.packageName?.toString()
                lastFocusedClass = event.className?.toString()
            }
            AccessibilityEvent.TYPE_VIEW_CLICKED -> {
                // Monitor clicks for context awareness
            }
            AccessibilityEvent.TYPE_VIEW_FOCUSED -> {
                // Track focus changes
            }
        }
    }

    private fun extractSelectedText(event: AccessibilityEvent) {
        val source = event.source ?: return
        selectedText = extractTextFromNode(source)
        source.recycle()
    }

    private fun extractTextFromNode(node: AccessibilityNodeInfo?): String? {
        node ?: return null

        // Try to get selected text first
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            try {
                if (node.isEditable) {
                    val text = node.text?.toString()
                    val min = node.textSelectionStart
                    val max = node.textSelectionEnd
                    if (text != null && min >= 0 && max > min) {
                        return text.substring(min, max)
                    }
                }
            } catch (e: Exception) {
                // Fall through to other methods
            }
        }

        // Try to get text from the node
        val nodeText = node.text?.toString()
        if (!nodeText.isNullOrBlank()) {
            return nodeText
        }

        // Try to get content description
        val contentDesc = node.contentDescription?.toString()
        if (!contentDesc.isNullOrBlank()) {
            return contentDesc
        }

        // Recurse through children
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            val childText = extractTextFromNode(child)
            if (!childText.isNullOrBlank()) {
                child.recycle()
                return childText
            }
            child?.recycle()
        }

        return null
    }

    override fun onInterrupt() {
        // Service interrupted
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        selectedText = null
    }

    fun getCurrentScreenText(): String? {
        val root = rootInActiveWindow ?: return null
        val text = extractTextFromNode(root)
        root.recycle()
        return text
    }

    fun injectText(text: String) {
        val root = rootInActiveWindow ?: return
        val focusedNode = root.findFocus(AccessibilityNodeInfo.FOCUS_INPUT)
        
        if (focusedNode != null && focusedNode.isEditable) {
            val args = Bundle().apply {
                putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, text)
            }
            focusedNode.performAction(
                AccessibilityNodeInfo.ACTION_SET_TEXT,
                args
            )
            focusedNode.recycle()
        }
        root.recycle()
    }
}
