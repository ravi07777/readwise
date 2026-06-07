import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/platform_channel_service.dart';
import '../../../../core/services/notification_service.dart';

class ClipboardAssistantState {
  final String? currentClipboardText;
  final bool isMonitoring;
  final bool showPrompt;
  final DateTime? lastChecked;

  const ClipboardAssistantState({
    this.currentClipboardText,
    this.isMonitoring = false,
    this.showPrompt = false,
    this.lastChecked,
  });

  ClipboardAssistantState copyWith({
    String? currentClipboardText,
    bool? isMonitoring,
    bool? showPrompt,
    DateTime? lastChecked,
  }) {
    return ClipboardAssistantState(
      currentClipboardText: currentClipboardText ?? this.currentClipboardText,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      showPrompt: showPrompt ?? this.showPrompt,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

final clipboardAssistantProvider =
    StateNotifierProvider<ClipboardAssistantNotifier, ClipboardAssistantState>((ref) {
  return ClipboardAssistantNotifier(ref.watch(platformChannelServiceProvider));
});

class ClipboardAssistantNotifier extends StateNotifier<ClipboardAssistantState> {
  final PlatformChannelService _platform;

  ClipboardAssistantNotifier(this._platform) : super(const ClipboardAssistantState());

  Future<void> startMonitoring() async {
    state = state.copyWith(isMonitoring: true);
    await _platform.startClipboardMonitoring();
  }

  void stopMonitoring() {
    state = state.copyWith(isMonitoring: false);
  }

  Future<String?> checkClipboard() async {
    final text = await _platform.getClipboardText();
    if (text != null && text.isNotEmpty && text != state.currentClipboardText) {
      state = state.copyWith(
        currentClipboardText: text,
        showPrompt: true,
        lastChecked: DateTime.now(),
      );

      if (state.isMonitoring) {
        await NotificationService.instance.showNotification(
          id: 100,
          title: 'Text Detected',
          body: 'Use copied text with AI Assistant?',
          payload: text,
        );
      }
    }
    return text;
  }

  void dismissPrompt() {
    state = state.copyWith(showPrompt: false);
  }

  String? getText() {
    final text = state.currentClipboardText;
    state = state.copyWith(showPrompt: false);
    return text;
  }
}
