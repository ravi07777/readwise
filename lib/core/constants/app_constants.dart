import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'ReadWise AI Assistant';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.readwise.ai';

  static const String databaseName = 'readwise.db';

  static const Duration overlayAnimationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration clipboardCheckInterval = Duration(seconds: 2);

  static const double floatingButtonSize = 56.0;
  static const double overlayCardMinWidth = 280.0;
  static const double overlayCardMaxWidth = 400.0;
  static const double overlayCardMinHeight = 200.0;
  static const double overlayCardMaxHeight = 500.0;

  static const double quickMenuWidth = 240.0;
  static const double quickMenuItemHeight = 48.0;

  static const int maxTokens = 4096;
  static const double defaultTemperature = 0.7;

  static const List<String> supportedLanguages = [
    'en',
    'hi',
    'ur',
    'es',
    'fr',
    'de',
    'zh',
    'ja',
    'ko',
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'Hindi',
    'ur': 'Urdu',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
  };

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('hi', 'IN'),
    Locale('ur', 'PK'),
  ];

  static const String defaultSystemPrompt = '''
You are ReadWise AI Assistant, a helpful reading companion. 
You help users understand difficult text by providing clear explanations, 
simplifications, translations, and insights. 
You adapt your responses to the user's reading level and preferences.
Keep responses concise and focused on the text being read.
''';
}
