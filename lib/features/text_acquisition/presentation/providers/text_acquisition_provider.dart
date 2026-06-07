import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/accessibility_service.dart';
import '../../../../core/services/platform_channel_service.dart';

class TextAcquisitionState {
  final String? selectedText;
  final String? clipboardText;
  final String? ocrText;
  final bool isLoading;
  final String? error;
  final AcquisitionSource source;

  const TextAcquisitionState({
    this.selectedText,
    this.clipboardText,
    this.ocrText,
    this.isLoading = false,
    this.error,
    this.source = AcquisitionSource.none,
  });

  String? get bestText {
    return selectedText ?? clipboardText ?? ocrText;
  }

  TextAcquisitionState copyWith({
    String? selectedText,
    String? clipboardText,
    String? ocrText,
    bool? isLoading,
    String? error,
    AcquisitionSource? source,
  }) {
    return TextAcquisitionState(
      selectedText: selectedText ?? this.selectedText,
      clipboardText: clipboardText ?? this.clipboardText,
      ocrText: ocrText ?? this.ocrText,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      source: source ?? this.source,
    );
  }
}

enum AcquisitionSource {
  none,
  accessibility,
  clipboard,
  ocr,
  share,
  manual,
}

final textAcquisitionProvider =
    StateNotifierProvider<TextAcquisitionNotifier, TextAcquisitionState>((ref) {
  return TextAcquisitionNotifier(
    ref.watch(accessibilityServiceProvider),
    ref.watch(platformChannelServiceProvider),
  );
});

class TextAcquisitionNotifier extends StateNotifier<TextAcquisitionState> {
  final AccessibilityService _accessibility;
  final PlatformChannelService _platform;

  TextAcquisitionNotifier(this._accessibility, this._platform)
      : super(const TextAcquisitionState());

  Future<String?> acquireText() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Priority 1: Selected text via Accessibility Service
      final selected = await _accessibility.getSelectedText();
      if (selected != null && selected.isNotEmpty) {
        state = state.copyWith(
          selectedText: selected,
          isLoading: false,
          source: AcquisitionSource.accessibility,
        );
        return selected;
      }

      // Priority 2: Clipboard text
      final clipboard = await _platform.getClipboardText();
      if (clipboard != null && clipboard.isNotEmpty) {
        state = state.copyWith(
          clipboardText: clipboard,
          isLoading: false,
          source: AcquisitionSource.clipboard,
        );
        return clipboard;
      }

      // Priority 3: OCR (triggered separately)
      state = state.copyWith(isLoading: false, source: AcquisitionSource.none);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<String?> acquireFromClipboard() async {
    final text = await _platform.getClipboardText();
    if (text != null && text.isNotEmpty) {
      state = state.copyWith(
        clipboardText: text,
        source: AcquisitionSource.clipboard,
      );
    }
    return text;
  }

  void setOcrText(String text) {
    state = state.copyWith(
      ocrText: text,
      source: AcquisitionSource.ocr,
    );
  }

  void setShareText(String text) {
    state = state.copyWith(
      selectedText: text,
      source: AcquisitionSource.share,
    );
  }

  void setManualText(String text) {
    state = state.copyWith(
      selectedText: text,
      source: AcquisitionSource.manual,
    );
  }

  void clear() {
    state = const TextAcquisitionState();
  }
}
