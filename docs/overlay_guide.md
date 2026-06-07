# Overlay Guide

## Overview

The overlay system allows ReadWise AI Assistant to work on top of any Android application. It consists of a draggable floating button that provides quick access to AI reading features.

## Components

### Floating Button
- Draggable Material 3 button
- Snaps to screen edges
- Persists position across sessions
- Double-tap and long-press gestures

### Service Lifecycle

```
App Launch
    ↓
Check Overlay Permission
    ↓
┌─── Has Permission? ───┐
│          │            │
│  Yes     │  No        │
│   │      │   │        │
│   ▼      │   ▼        │
│ Start    │ Request    │
│ Service  │ Permission │
│   │      │   │        │
│   ▼      │   ▼        │
│ Button   │ Granted?   │
│ Visible  │  │     │   │
│          │ Yes   No  │
│          │  │     │   │
│          │  ▼     ▼   │
│          │ Start  App │
│          │ Serv.  Only │
└──────────┴────────────┘
```

## Android Implementation

### OverlayService.kt
The Android service that creates and manages the overlay window:

```kotlin
class OverlayService : Service() {
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Create notification
        // Show overlay button
        return START_STICKY
    }
}
```

### Key Features

1. **Window Type:** Uses `TYPE_APPLICATION_OVERLAY` (API 26+) or `TYPE_PHONE` (legacy)
2. **Touch Handling:** Custom touch listener for drag, tap, and long-press
3. **Position Persistence:** Saves position to SharedPreferences
4. **Edge Snapping:** Automatically snaps to nearest screen edge
5. **Foreground Service:** Runs as foreground service for reliability

## Flutter Integration

### Starting the Overlay
```dart
final started = await OverlayService.instance.startOverlay();
```

### Stopping the Overlay
```dart
await OverlayService.instance.stopOverlay();
```

### Position Management
```dart
final position = await OverlayService.instance.getOverlayPosition();
await OverlayService.instance.updateOverlayPosition(x, y);
```

## Quick Action Menu

Tapping the floating button opens the Quick Action Menu with options:
- Capture Screen
- Select Screen Region
- Paste Copied Text
- Explain
- Summarize
- Translate
- Simplify English
- Generate Notes
- Ask AI Question

## Response Cards

AI responses appear in floating overlay cards that:
- Display above other apps
- Can be expanded/collapsed
- Support copy, save, and share actions
- Allow follow-up questions

## Troubleshooting

### Overlay Not Appearing
1. Check overlay permission in system settings
2. Ensure the service is running (check notifications)
3. Restart the app

### Button Position Reset
- Positions are stored locally and persist across sessions
- If reset occurs, check storage permissions

### Service Killed by System
- Android may kill foreground services under memory pressure
- The service restarts automatically via START_STICKY
- Boot receiver restarts service after reboot if enabled
