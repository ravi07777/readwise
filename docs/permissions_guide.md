# Permissions Guide

## Required Permissions

### SYSTEM_ALERT_WINDOW
**Purpose:** Display floating assistant button above other apps.

**When requested:** When user enables "Floating Assistant" in Settings.

**How to grant:**
1. Tap "Enable" in the overlay settings
2. Android will open system settings for overlay permission
3. Toggle "Allow display over other apps"

**If denied:** The floating button will not appear. The app functions in non-overlay mode.

---

### FOREGROUND_SERVICE
**Purpose:** Keep overlay and screen capture services running.

**When requested:** Automatically when overlay or screen capture is active.

**Note:** This is required for Android 8+ to run background services reliably.

---

### BIND_ACCESSIBILITY_SERVICE
**Purpose:** Read text from other apps, detect text selection, and extract screen content.

**When requested:** Settings > Accessibility > ReadWise AI Assistant.

**How to grant:**
1. Go to Android Settings > Accessibility
2. Find "ReadWise AI Assistant" in installed apps
3. Toggle the service on
4. Confirm the prompt about data access

**Privacy note:** Accessibility data is only used for text extraction and is never stored or transmitted outside the app without explicit user action.

---

### MEDIA_PROJECTION
**Purpose:** Capture screen content for OCR (Optical Character Recognition).

**When requested:** When user selects "Capture Screen" or "Select Screen Region" from the floating menu.

**How to grant:**
1. Tap "Capture Screen" from the quick menu
2. Android will show a confirmation dialog
3. Tap "Start now" or "Allow"

**Privacy note:** Screen captures are only processed locally for OCR. Images are discarded after text extraction unless user explicitly saves them.

---

### INTERNET
**Purpose:** Send text to AI providers for processing.

**When requested:** When user sends text to an AI provider for explanation, translation, etc.

**Privacy note:** Only the explicitly selected text is sent to the AI provider. No other data is transmitted.

---

### POST_NOTIFICATIONS (Android 13+)
**Purpose:** Show notification for overlay service, screen capture service, and clipboard detection.

**When requested:** When services are first started.

---

## Permission Flow

```
Feature Requested
    ↓
Check Permission Status
    ↓
┌─── Granted? ───┐
│       │        │
│  Yes   │  No    │
│   │    │    │   │
│   ▼    │    ▼   │
│ Use    │ Request│
│ Feature│ Perm.  │
│        │    │   │
│        │    ▼   │
│        │ Granted│
│        │    │   │
│        │  ┌─┴─┐ │
│        │ Yes  No│
│        │  │    ││
│        │  ▼    ▼│
│        │ Use  Show│
│        │ Feat.Error│
└────────┴─────────┘
```

## Debugging Permissions

### Check overlay permission programmatically:
```dart
final hasOverlay = await OverlayService.instance.isOverlayRunning();
```

### Check accessibility service status:
```dart
final isEnabled = await AccessibilityService.instance.isAccessibilityEnabled();
```

### Request overlay permission:
```dart
await OverlayService.instance.startOverlay();
```

## Best Practices

1. **Request permissions lazily** - Only request when the feature is actually used
2. **Handle denial gracefully** - Show explanation why permission is needed
3. **Provide alternative paths** - If overlay is denied, allow accessing features through the app UI
4. **Respect user privacy** - Only collect minimum data needed for functionality
