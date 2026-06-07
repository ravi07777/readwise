# GitHub Actions Guide

## Overview

GitHub Actions automate the build, test, and release process for ReadWise AI Assistant.

## Workflows

### CI Workflow (`.github/workflows/ci.yml`)

Triggers on: Push to `main`/`develop`, Pull requests to `main`

**Jobs:**

#### 1. Analyze & Lint
- Installs Flutter
- Gets dependencies
- Generates code (Freezed, Isar, JsonSerializable)
- Runs Dart analyzer
- Checks code formatting

#### 2. Run Tests
- Installs Flutter
- Gets dependencies
- Generates code
- Runs all unit tests with coverage
- Uploads coverage to Codecov

#### 3. Build APK
- Installs Flutter
- Gets dependencies
- Generates code
- Builds debug APK for arm64
- Uploads APK as artifact

#### 4. Build App Bundle
- Installs Flutter
- Gets dependencies
- Generates code
- Builds debug App Bundle
- Uploads AAB as artifact

### Release Workflow (`.github/workflows/release.yml`)

Triggers on: Tags matching `v*.*.*`

**Jobs:**

#### 1. Build Release
- Installs Flutter
- Gets dependencies
- Generates code
- Runs all tests
- Builds release APK (arm + arm64)
- Builds release App Bundle
- Signs APK (requires secrets)
- Creates GitHub Release
- Uploads APK and AAB as release assets

#### 2. Deploy to Play Store (disabled by default)
- Builds release App Bundle
- Uploads to Google Play Console
- Requires Play Store service account credentials

## Required Secrets

For the release workflow, configure these secrets in your GitHub repository:

### Settings > Secrets and variables > Actions

| Secret | Description |
|--------|-------------|
| `SIGNING_KEY_STORE` | Base64-encoded Android keystore file |
| `SIGNING_KEY_ALIAS` | Key alias in the keystore |
| `SIGNING_KEY_PASSWORD` | Key password |
| `SIGNING_STORE_PASSWORD` | Keystore password |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Google Play service account JSON (for auto-deploy) |

### Setting Up Signing

1. Generate a keystore:
```bash
keytool -genkey -v -keystore readwise.keystore -alias readwise \
  -keyalg RSA -keysize 2048 -validity 10000
```

2. Base64 encode it:
```bash
base64 -i readwise.keystore
```

3. Add the encoded string as `SIGNING_KEY_STORE` secret

4. Configure signing in `android/app/build.gradle`:
```gradle
signingConfigs {
    release {
        storeFile file('/tmp/keystore.jks')
        storePassword System.getenv('SIGNING_STORE_PASSWORD')
        keyAlias System.getenv('SIGNING_KEY_ALIAS')
        keyPassword System.getenv('SIGNING_KEY_PASSWORD')
    }
}
```

## Running Workflows Locally

You can test workflows locally using `act`:
```bash
# Install act
brew install act

# Run CI workflow
act push

# Run specific job
act -j test
```

## Customizing Workflows

### Adding New Target Platforms
To build for additional Android architectures:
```yaml
- name: Build APK
  run: flutter build apk --release --target-platform android-arm,android-arm64,x86_64
```

### Adding Code Quality Checks
```yaml
- name: Custom lint check
  run: flutter pub run custom_lint
```

### Adding Integration Tests
```yaml
- name: Run integration tests
  run: flutter test integration_test/
```

## Best Practices

1. **Keep secrets secure** - Never commit API keys or passwords
2. **Cache dependencies** - Use `actions/cache` for faster builds
3. **Use matrix builds** - Test across multiple Flutter versions
4. **Monitor workflow runs** - Set up notifications for failures
5. **Version tags** - Use semantic versioning (v1.0.0, v1.1.0, etc.)
