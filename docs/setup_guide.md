# Setup Guide

## Prerequisites

### Required Software
- **Flutter SDK** 3.19.0 or higher
- **Android Studio** Hedgehog (2023.1.1) or newer
- **Java** 17 (bundled with Android Studio)
- **Git**

### Android Requirements
- Target SDK: 34
- Min SDK: 23 (Android 6.0)
- Kotlin version: 1.9.22
- Gradle version: 8.1+

## Initial Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/readwise-ai-assistant.git
cd readwise-ai-assistant
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Generate Code
Run the code generator for Freezed, JsonSerializable, and Isar:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configure Android SDK
Ensure `local.properties` exists in the `android/` directory:
```properties
sdk.dir=/path/to/Android/sdk
flutter.sdk=/path/to/flutter
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
```

### 5. Run the Application
```bash
flutter run
```

## Build Variants

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## Development Setup

### Code Generation Watch Mode
For continuous code generation during development:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/core/ai_client_test.dart
```

### Linting
```bash
flutter analyze
```

## Troubleshooting

### Build Failures
- Ensure Java 17 is used: `java -version`
- Clear Flutter build cache: `flutter clean`
- Regenerate code: `flutter pub run build_runner build --delete-conflicting-outputs`

### Overlay Permission Issues
- Go to Settings > Apps > ReadWise AI > Display over other apps
- Enable the permission manually if the prompt doesn't appear

### Accessibility Service
- Go to Settings > Accessibility > ReadWise AI Assistant
- Toggle the service on
- Grant necessary permissions

### API Connection Issues
- Verify your API key is correct
- Check internet connectivity
- Ensure the selected provider is available in your region
- For Ollama, verify the local server is running
