import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/platform_channel_service.dart';

class ScreenCaptureState {
  final bool isCapturing;
  final bool hasResult;
  final String? ocrText;
  final double? confidence;
  final bool isLoading;

  const ScreenCaptureState({
    this.isCapturing = false,
    this.hasResult = false,
    this.ocrText,
    this.confidence,
    this.isLoading = false,
  });

  ScreenCaptureState copyWith({
    bool? isCapturing,
    bool? hasResult,
    String? ocrText,
    double? confidence,
    bool? isLoading,
  }) {
    return ScreenCaptureState(
      isCapturing: isCapturing ?? this.isCapturing,
      hasResult: hasResult ?? this.hasResult,
      ocrText: ocrText ?? this.ocrText,
      confidence: confidence ?? this.confidence,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final screenCaptureProvider =
    StateNotifierProvider<ScreenCaptureNotifier, ScreenCaptureState>((ref) {
  return ScreenCaptureNotifier(ref.watch(platformChannelServiceProvider));
});

class ScreenCaptureNotifier extends StateNotifier<ScreenCaptureState> {
  final PlatformChannelService _platform;

  ScreenCaptureNotifier(this._platform) : super(const ScreenCaptureState());

  Future<void> startCapture() async {
    state = state.copyWith(isCapturing: true, isLoading: true);
    // Trigger native screen capture
    state = state.copyWith(isCapturing: false, isLoading: false);
  }

  void setOcrResult(String text, double confidence) {
    state = state.copyWith(
      ocrText: text,
      confidence: confidence,
      hasResult: true,
      isLoading: false,
    );
  }

  Future<void> captureFullScreen() async {
    state = state.copyWith(isLoading: true);
    // Full screen capture implementation
    state = state.copyWith(isLoading: false);
  }

  void clear() {
    state = const ScreenCaptureState();
  }
}
