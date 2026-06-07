import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:readwise_ai_assistant/core/services/accessibility_service.dart';
import 'package:readwise_ai_assistant/core/services/platform_channel_service.dart';
import 'package:readwise_ai_assistant/features/text_acquisition/presentation/providers/text_acquisition_provider.dart';

class MockAccessibilityService extends Mock implements AccessibilityService {}
class MockPlatformChannelService extends Mock implements PlatformChannelService {}

void main() {
  late MockAccessibilityService mockAccessibility;
  late MockPlatformChannelService mockPlatform;
  late TextAcquisitionNotifier notifier;

  setUp(() {
    mockAccessibility = MockAccessibilityService();
    mockPlatform = MockPlatformChannelService();
    notifier = TextAcquisitionNotifier(mockAccessibility, mockPlatform);
  });

  group('TextAcquisitionNotifier', () {
    test('initial state should be empty', () {
      expect(notifier.state.selectedText, isNull);
      expect(notifier.state.clipboardText, isNull);
      expect(notifier.state.ocrText, isNull);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.source, equals(AcquisitionSource.none));
    });

    test('should acquire text from accessibility service first', () async {
      when(() => mockAccessibility.getSelectedText())
          .thenAnswer((_) async => 'Selected text from accessibility');
      when(() => mockPlatform.getClipboardText())
          .thenAnswer((_) async => 'Clipboard text');

      final result = await notifier.acquireText();

      expect(result, equals('Selected text from accessibility'));
      expect(notifier.state.source, equals(AcquisitionSource.accessibility));
      expect(notifier.state.selectedText, equals('Selected text from accessibility'));
    });

    test('should fall back to clipboard when no selected text', () async {
      when(() => mockAccessibility.getSelectedText())
          .thenAnswer((_) async => null);
      when(() => mockPlatform.getClipboardText())
          .thenAnswer((_) async => 'Clipboard text');

      final result = await notifier.acquireText();

      expect(result, equals('Clipboard text'));
      expect(notifier.state.source, equals(AcquisitionSource.clipboard));
      expect(notifier.state.clipboardText, equals('Clipboard text'));
    });

    test('should return null when no text available', () async {
      when(() => mockAccessibility.getSelectedText())
          .thenAnswer((_) async => null);
      when(() => mockPlatform.getClipboardText())
          .thenAnswer((_) async => null);

      final result = await notifier.acquireText();

      expect(result, isNull);
      expect(notifier.state.source, equals(AcquisitionSource.none));
    });

    test('should prioritize selected text over clipboard', () async {
      when(() => mockAccessibility.getSelectedText())
          .thenAnswer((_) async => 'Selected');
      when(() => mockPlatform.getClipboardText())
          .thenAnswer((_) async => 'Clipboard');

      final result = await notifier.acquireText();
      expect(result, equals('Selected'));
    });

    test('should handle errors gracefully', () async {
      when(() => mockAccessibility.getSelectedText())
          .thenThrow(Exception('Accessibility error'));

      final result = await notifier.acquireText();

      expect(result, isNull);
      expect(notifier.state.error, isNotNull);
    });

    test('should set OCR text correctly', () {
      notifier.setOcrText('OCR result');
      expect(notifier.state.ocrText, equals('OCR result'));
      expect(notifier.state.source, equals(AcquisitionSource.ocr));
    });

    test('should clear state correctly', () {
      notifier.setOcrText('some text');
      notifier.clear();
      expect(notifier.state.source, equals(AcquisitionSource.none));
      expect(notifier.state.selectedText, isNull);
    });
  });
}
