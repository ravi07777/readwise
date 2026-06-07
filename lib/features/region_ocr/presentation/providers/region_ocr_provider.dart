import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegionOCRState {
  final bool isSelecting;
  final Rect? selectedRegion;
  final String? ocrText;
  final bool isLoading;

  const RegionOCRState({
    this.isSelecting = false,
    this.selectedRegion,
    this.ocrText,
    this.isLoading = false,
  });

  RegionOCRState copyWith({
    bool? isSelecting,
    Rect? selectedRegion,
    String? ocrText,
    bool? isLoading,
  }) {
    return RegionOCRState(
      isSelecting: isSelecting ?? this.isSelecting,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      ocrText: ocrText ?? this.ocrText,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final regionOCRProvider =
    StateNotifierProvider<RegionOCRNotifier, RegionOCRState>((ref) {
  return RegionOCRNotifier();
});

class RegionOCRNotifier extends StateNotifier<RegionOCRState> {
  RegionOCRNotifier() : super(const RegionOCRState());

  void startSelection() {
    state = state.copyWith(isSelecting: true);
  }

  void setRegion(Rect region) {
    state = state.copyWith(selectedRegion: region, isSelecting: false);
  }

  void setOcrResult(String text) {
    state = state.copyWith(ocrText: text, isLoading: false);
  }

  void cancelSelection() {
    state = state.copyWith(isSelecting: false, selectedRegion: null);
  }

  void clear() {
    state = const RegionOCRState();
  }
}
