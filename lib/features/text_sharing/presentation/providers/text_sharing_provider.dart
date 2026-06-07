import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/platform_channel_service.dart';

class TextSharingState {
  final String? sharedText;
  final bool hasSharedText;
  final String? source;

  const TextSharingState({
    this.sharedText,
    this.hasSharedText = false,
    this.source,
  });

  TextSharingState copyWith({
    String? sharedText,
    bool? hasSharedText,
    String? source,
  }) {
    return TextSharingState(
      sharedText: sharedText ?? this.sharedText,
      hasSharedText: hasSharedText ?? this.hasSharedText,
      source: source ?? this.source,
    );
  }
}

final textSharingProvider =
    StateNotifierProvider<TextSharingNotifier, TextSharingState>((ref) {
  return TextSharingNotifier(ref.watch(platformChannelServiceProvider));
});

class TextSharingNotifier extends StateNotifier<TextSharingState> {
  final PlatformChannelService _platform;

  TextSharingNotifier(this._platform) : super(const TextSharingState());

  Future<void> checkForSharedText() async {
    final text = await _platform.getSharedText();
    if (text != null && text.isNotEmpty) {
      state = state.copyWith(
        sharedText: text,
        hasSharedText: true,
        source: 'share',
      );
    }
  }

  void clear() {
    state = const TextSharingState();
  }
}
