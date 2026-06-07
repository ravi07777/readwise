import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/secure_storage_service.dart';

class AppSettings {
  final Locale locale;
  final bool overlayEnabled;
  final bool accessibilityEnabled;
  final bool clipboardMonitoring;
  final bool autoOCREnabled;
  final bool showNotifications;
  final String defaultPromptId;
  final String defaultProvider;
  final String defaultModel;
  final double defaultTemperature;
  final int defaultMaxTokens;
  final bool darkMode;
  final bool dynamicColors;
  final bool animationsEnabled;
  final bool hapticFeedback;

  const AppSettings({
    this.locale = const Locale('en', 'US'),
    this.overlayEnabled = false,
    this.accessibilityEnabled = false,
    this.clipboardMonitoring = false,
    this.autoOCREnabled = false,
    this.showNotifications = true,
    this.defaultPromptId = '',
    this.defaultProvider = 'openai',
    this.defaultModel = 'gpt-4o',
    this.defaultTemperature = 0.7,
    this.defaultMaxTokens = 4096,
    this.darkMode = false,
    this.dynamicColors = true,
    this.animationsEnabled = true,
    this.hapticFeedback = true,
  });

  AppSettings copyWith({
    Locale? locale,
    bool? overlayEnabled,
    bool? accessibilityEnabled,
    bool? clipboardMonitoring,
    bool? autoOCREnabled,
    bool? showNotifications,
    String? defaultPromptId,
    String? defaultProvider,
    String? defaultModel,
    double? defaultTemperature,
    int? defaultMaxTokens,
    bool? darkMode,
    bool? dynamicColors,
    bool? animationsEnabled,
    bool? hapticFeedback,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      overlayEnabled: overlayEnabled ?? this.overlayEnabled,
      accessibilityEnabled: accessibilityEnabled ?? this.accessibilityEnabled,
      clipboardMonitoring: clipboardMonitoring ?? this.clipboardMonitoring,
      autoOCREnabled: autoOCREnabled ?? this.autoOCREnabled,
      showNotifications: showNotifications ?? this.showNotifications,
      defaultPromptId: defaultPromptId ?? this.defaultPromptId,
      defaultProvider: defaultProvider ?? this.defaultProvider,
      defaultModel: defaultModel ?? this.defaultModel,
      defaultTemperature: defaultTemperature ?? this.defaultTemperature,
      defaultMaxTokens: defaultMaxTokens ?? this.defaultMaxTokens,
      darkMode: darkMode ?? this.darkMode,
      dynamicColors: dynamicColors ?? this.dynamicColors,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier(ref.watch(secureStorageServiceProvider));
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final SecureStorageService _storage;

  AppSettingsNotifier(this._storage) : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      locale: Locale(prefs.getString('locale') ?? 'en', 'US'),
      overlayEnabled: prefs.getBool('overlay_enabled') ?? false,
      accessibilityEnabled: prefs.getBool('accessibility_enabled') ?? false,
      clipboardMonitoring: prefs.getBool('clipboard_monitoring') ?? false,
      autoOCREnabled: prefs.getBool('auto_ocr_enabled') ?? false,
      showNotifications: prefs.getBool('show_notifications') ?? true,
      defaultPromptId: prefs.getString('default_prompt_id') ?? '',
      defaultProvider: prefs.getString('default_provider') ?? 'openai',
      defaultModel: prefs.getString('default_model') ?? 'gpt-4o',
      defaultTemperature: prefs.getDouble('default_temperature') ?? 0.7,
      defaultMaxTokens: prefs.getInt('default_max_tokens') ?? 4096,
      darkMode: prefs.getBool('dark_mode') ?? false,
      dynamicColors: prefs.getBool('dynamic_colors') ?? true,
      animationsEnabled: prefs.getBool('animations_enabled') ?? true,
      hapticFeedback: prefs.getBool('haptic_feedback') ?? true,
    );
  }

  Future<void> updateSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
    await _loadSettings();
  }

  Future<void> updateOverlayEnabled(bool enabled) async {
    await updateSetting('overlay_enabled', enabled);
  }

  Future<void> updateClipboardMonitoring(bool enabled) async {
    await updateSetting('clipboard_monitoring', enabled);
  }
}
