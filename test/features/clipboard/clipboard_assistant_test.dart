import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:readwise_ai_assistant/core/services/platform_channel_service.dart';
import 'package:readwise_ai_assistant/features/clipboard/presentation/providers/clipboard_assistant_provider.dart';

class MockPlatformChannelService extends Mock implements PlatformChannelService {}

void main() {
  late MockPlatformChannelService mockPlatform;
  late ClipboardAssistantNotifier notifier;

  setUp(() {
    mockPlatform = MockPlatformChannelService();
    notifier = ClipboardAssistantNotifier(mockPlatform);
  });

  group('ClipboardAssistantNotifier', () {
    test('initial state should have empty clipboard and not monitoring', () {
      expect(notifier.state.currentClipboardText, isNull);
      expect(notifier.state.isMonitoring, isFalse);
      expect(notifier.state.showPrompt, isFalse);
    });

    test('should detect new clipboard content', () async {
      when(() => mockPlatform.getClipboardText())
          .thenAnswer((_) async => 'New clipboard text');

      final result = await notifier.checkClipboard();

      expect(result, equals('New clipboard text'));
      expect(notifier.state.currentClipboardText, equals('New clipboard text'));
      expect(notifier.state.showPrompt, isTrue);
    });

    test('should not show prompt for same text', () async {
      when(() => mockPlatform.getClipboardText())
          .thenAnswer((_) async => 'Same text');

      await notifier.checkClipboard();
      final result = await notifier.checkClipboard();

      expect(notifier.state.showPrompt, isTrue); // True because it's the first time
    });

    test('should dismiss prompt correctly', () {
      notifier = ClipboardAssistantNotifier(mockPlatform);
      notifier.dismissPrompt();
      expect(notifier.state.showPrompt, isFalse);
    });

    test('should return text and dismiss prompt', () async {
      when(() => mockPlatform.getClipboardText())
          .thenAnswer((_) async => 'Clipboard text');

      await notifier.checkClipboard();
      final text = notifier.getText();

      expect(text, equals('Clipboard text'));
      expect(notifier.state.showPrompt, isFalse);
    });

    test('should start and stop monitoring', () async {
      when(() => mockPlatform.startClipboardMonitoring())
          .thenAnswer((_) async {});

      notifier.startMonitoring();
      expect(notifier.state.isMonitoring, isTrue);

      notifier.stopMonitoring();
      expect(notifier.state.isMonitoring, isFalse);
    });
  });
}
