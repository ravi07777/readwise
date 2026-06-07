# Architecture Guide

## Overview

ReadWise AI Assistant follows **Clean Architecture** principles with a **feature-first** project structure. This ensures separation of concerns, testability, and maintainability.

## Architecture Layers

### Core Layer (`lib/core/`)
Shared infrastructure used across all features.

```
core/
├── constants/       # App and API constants
├── theme/           # Material 3 theming (light/dark)
├── router/          # GoRouter configuration
├── services/        # Platform services (overlay, accessibility, etc.)
├── database/        # Isar database service
├── network/         # HTTP client, AI provider implementations
├── utils/           # Helper utilities
└── extensions/      # Dart extension methods
```

### Feature Layer (`lib/features/`)
Each feature is self-contained with its own layers.

```
feature_name/
├── presentation/    # UI screens, widgets, providers (Riverpod)
├── domain/         # Use cases, repository interfaces
└── data/           # Repository implementations, DTOs, data sources
```

### Shared Layer (`lib/shared/`)
Reusable components used across features.

```
shared/
├── models/         # Isar database models
├── widgets/        # Shared UI components
└── providers/      # Shared state providers
```

## State Management

The app uses **Riverpod** for state management.

### Provider Types
- `Provider` - Simple dependency injection
- `StateProvider` - Simple state
- `StateNotifierProvider` - Complex state with logic
- `FutureProvider` - Async data
- `StreamProvider` - Stream data

### State Management Patterns
- UI components read state via `ref.watch()`
- Actions are triggered via `ref.read().method()`
- State is immutable with `copyWith()` pattern

## Navigation

**GoRouter** handles all navigation with:
- Shell routes for bottom navigation
- Named routes for feature screens
- Deep linking support

```dart
GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomeScreen(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => ChatScreen()),
        GoRoute(path: '/memory', ...),
        GoRoute(path: '/intelligence', ...),
        // etc.
      ],
    ),
  ],
);
```

## Database

**Isar** is used for local storage with the following collections:
- Prompt, Note, Flashcard
- ReadingSession, Conversation, Message
- VocabularyWord, Phrase, Idiom
- Summary, Bookmark, ReadingHighlight

### Database Service Pattern
```dart
final db = ref.read(databaseServiceProvider);
await db.saveNote(Note(title: '...', content: '...'));
final notes = await db.getAllNotes();
```

## Dependency Injection

Dependencies are injected via Riverpod providers:

```dart
final aiClientProvider = Provider<AIClient>((ref) {
  return AIClient(storage: ref.watch(secureStorageServiceProvider));
});
```

## Platform Channels

Native Android functionality is accessed through method channels:

| Channel | Purpose |
|---------|---------|
| `com.readwise.ai/overlay` | Floating overlay service |
| `com.readwise.ai/accessibility` | Accessibility service |
| `com.readwise.ai/screenshot` | Screen capture via MediaProjection |
| `com.readwise.ai/ocr` | ML Kit OCR processing |
| `com.readwise.ai/clipboard_native` | Native clipboard access |
| `com.readwise.ai/platform` | Device info, permissions |
| `com.readwise.ai/share` | Share intent handling |

## Data Flow

```
User Action → Widget → Provider/Notifier → Repository → Data Source
                                                              ↓
User sees UI ← Widget ← State Change ← Provider ← Repository ←
```

## Testing Strategy

- **Unit Tests:** Providers, use cases, repositories
- **Widget Tests:** UI components
- **Integration Tests:** Feature workflows
- **Coverage Target:** >80%
