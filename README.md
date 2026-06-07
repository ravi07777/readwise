# ReadWise AI Assistant

An AI-powered reading assistant overlay for Android that helps users understand difficult text while reading in any app.

## Overview

ReadWise AI Assistant is NOT an ebook reader. It is an AI-powered reading overlay that works on top of ANY Android application:

- EPUB readers
- PDF readers
- Kindle
- Browsers
- Research paper readers
- Documentation apps
- Note-taking apps

## Features

### Floating AI Assistant
- Draggable floating button that works above other apps
- Edge snapping for convenient placement
- Long press and tap gestures
- Position persistence across sessions

### Smart Text Acquisition
Priority-based text acquisition:
1. Selected text (via Accessibility Service)
2. Clipboard text
3. OCR text (via screen capture)

### Reading Assistant Actions
- Explain (Beginner/Teacher/Professor)
- Simplify English
- Translate (Hindi/Urdu/Hinglish)
- Summarize (Page/Chapter/Paragraph)
- Define Words, Phrases, Idioms
- Generate Notes, Flashcards, Quizzes
- Research Paper, Academic, Legal, Medical Simplifiers
- Book Discussion, Reading Coach

### AI Providers
- OpenAI (GPT-4o, GPT-4, GPT-3.5)
- Gemini (Pro, Flash)
- Anthropic (Claude 3 Opus/Sonnet/Haiku)
- OpenRouter
- Groq
- DeepSeek
- Ollama (local)
- Custom OpenAI-compatible endpoints

### Context Memory
- Reading history with session tracking
- Conversation history
- Saved notes, flashcards, summaries
- Vocabulary, phrases, and idioms collection
- Bookmarks and highlights

### Reading Intelligence
- Vocabulary Builder
- Flashcard system with spaced repetition
- Reading analytics and statistics
- Learning progress tracking
- Daily insights

### Privacy First
- No ads
- No analytics
- No tracking
- No account required
- Only selected text is sent to AI providers
- Everything else stays local

## Tech Stack

- **Framework:** Flutter with Material 3
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Data Models:** Freezed
- **Networking:** Dio
- **Database:** Isar (local)
- **Architecture:** Clean Architecture with feature-first structure
- **AI:** Multiple provider support (OpenAI, Gemini, Anthropic, OpenRouter, Groq, DeepSeek, Ollama)

## Architecture

```
lib/
├── core/           # Shared infrastructure
│   ├── constants/
│   ├── theme/
│   ├── router/
│   ├── services/
│   ├── database/
│   └── network/
├── features/       # Feature modules
│   ├── floating_assistant/
│   ├── quick_menu/
│   ├── text_acquisition/
│   ├── clipboard/
│   ├── screen_capture/
│   ├── region_ocr/
│   ├── text_sharing/
│   ├── reading_actions/
│   ├── context_memory/
│   ├── reading_chat/
│   ├── ai_providers/
│   ├── prompt_library/
│   ├── reading_intelligence/
│   └── overlay_response/
└── shared/         # Shared widgets and models
    ├── models/
    ├── widgets/
    └── providers/
```

Each feature follows Clean Architecture:
- **presentation/** - UI, providers, widgets
- **domain/** - Use cases, repositories interfaces
- **data/** - Repository implementations, data sources

## Getting Started

### Prerequisites
- Flutter SDK 3.19+
- Android Studio / VS Code
- Android device or emulator running API 23+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/readwise-ai-assistant.git
cd readwise-ai-assistant
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

### Configuration

1. Open the app and navigate to Settings
2. Enable the Floating Assistant (requires overlay permission)
3. Enable Accessibility Service for text detection
4. Add your AI provider API key in AI Providers settings
5. Select your preferred provider and model

## Required Permissions

- **SYSTEM_ALERT_WINDOW:** Required for floating overlay button
- **FOREGROUND_SERVICE:** Required for overlay and screen capture services
- **BIND_ACCESSIBILITY_SERVICE:** Required for text detection in other apps
- **MEDIA_PROJECTION:** Required for screen capture and OCR
- **INTERNET:** Required for AI API calls
- **POST_NOTIFICATIONS:** Required for service notifications (Android 13+)

## Documentation

- [Setup Guide](docs/setup_guide.md)
- [Architecture Guide](docs/architecture_guide.md)
- [Permissions Guide](docs/permissions_guide.md)
- [Overlay Guide](docs/overlay_guide.md)
- [OCR Guide](docs/ocr_guide.md)
- [AI Provider Guide](docs/ai_provider_guide.md)
- [Prompt System Guide](docs/prompt_system_guide.md)
- [GitHub Actions Guide](docs/github_actions_guide.md)

## License

MIT License - see LICENSE file for details
