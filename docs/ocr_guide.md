# OCR Guide

## Overview

ReadWise AI Assistant uses **Google ML Kit Text Recognition** for OCR (Optical Character Recognition). This allows the app to extract text from screen captures, enabling text acquisition even when direct text access is not available.

## OCR Pipeline

```
User taps "Capture Screen"
    ↓
Request MediaProjection Permission
    ↓
Start Virtual Display
    ↓
Capture Screen Image
    ↓
Process with ML Kit OCR
    ↓
┌─── Language Detection ───┐
│          │               │
│  Latin   │  Other        │
│   │      │   │           │
│   ▼      │   ▼           │
│ Latin    │ Chinese/      │
│ OCR      │ Devanagari/   │
│          │ Japanese/     │
│          │ Korean OCR    │
│          │               │
└──────────┴───────────────┘
    ↓
Extract Text
    ↓
Send to AI or Display
```

## ML Kit Integration

### Supported Languages
- **Latin:** English, Spanish, French, German, Italian, Portuguese, and more
- **Chinese:** Simplified and Traditional
- **Devanagari:** Hindi, Sanskrit, Marathi, Nepali
- **Japanese**
- **Korean**

### Native Implementation (`OcrProcessor.kt`)

```kotlin
class OcrProcessor {
    private val latinRecognizer = TextRecognition.getClient(
        TextRecognizerOptions.Builder().build()
    )

    suspend fun recognizeText(byteArray: ByteArray): OcrResult {
        // Decode bitmap
        // Try Latin OCR first
        // Fall back to other recognizers if needed
    }
}
```

### Performance Optimizations

1. **Language Detection:** Tries Latin first, falls back to other recognizers
2. **Bitmap Optimization:** Maintains quality while managing memory
3. **Async Processing:** All OCR runs on IO dispatcher
4. **Confidence Scoring:** Returns confidence level with results

## Screen Capture

### Full Screen Capture
Captures the entire screen using MediaProjection API:

```kotlin
MediaProjectionService.captureScreenshot { byteArray ->
    // Process with OCR
}
```

### Region OCR
Allows users to select a specific area:

```kotlin
MediaProjectionService.captureRegion(left, top, right, bottom) { byteArray ->
    // Process selected region with OCR
}
```

## Usage Flow

### From Quick Menu
1. Tap floating button
2. Select "Capture Screen" or "Select Screen Region"
3. Grant MediaProjection permission (first time only)
4. Screen is captured
5. OCR processes the image
6. Extracted text appears in response card
7. User can apply AI actions on the text

### Auto OCR
When enabled in Settings, the app will automatically:
1. Check for selected text (via Accessibility)
2. Check clipboard
3. If neither exists, perform OCR on current screen

## Privacy

- Screen captures are processed locally on device
- Images are discarded immediately after text extraction
- Only extracted text is used for AI processing (with user consent)
- No images or extracted text are stored without explicit user action

## Troubleshooting

### OCR Returns Empty Text
- Ensure the screen contains readable text
- Check screen brightness (very dim screens may affect OCR)
- Try with different language recognition
- Ensure MediaProjection permission is granted

### Poor OCR Quality
- Use high screen resolution
- Ensure good contrast between text and background
- Avoid screens with complex graphics/overlays
- Try region OCR for specific text areas

### Permission Issues
- MediaProjection permission must be granted each session
- System may revoke permission if app is in background
- Re-trigger capture to re-request permission

## Performance

- OCR processing typically takes 1-3 seconds
- Large texts may take longer
- Processing is done asynchronously to avoid UI freezes
- Results are cached for the current session
