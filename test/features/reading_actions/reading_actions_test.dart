import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:readwise_ai_assistant/core/network/ai_client.dart';
import 'package:readwise_ai_assistant/core/database/database_service.dart';
import 'package:readwise_ai_assistant/shared/models/isar_models.dart';
import 'package:readwise_ai_assistant/features/reading_actions/presentation/providers/reading_actions_provider.dart';

class MockAIClient extends Mock implements AIClient {}
class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late MockAIClient mockAiClient;
  late MockDatabaseService mockDb;
  late ReadingActionsNotifier notifier;

  setUp(() {
    mockAiClient = MockAIClient();
    mockDb = MockDatabaseService();
    notifier = ReadingActionsNotifier(mockAiClient, mockDb);
  });

  group('ReadingActionsNotifier', () {
    const testText = 'This is a complex text that needs explanation.';
    const expectedResponse = 'This is the explanation of the text...';

    test('initial state should be empty', () {
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.result, isNull);
      expect(notifier.state.error, isNull);
      expect(notifier.state.currentAction, isNull);
    });

    test('should execute explain action successfully', () async {
      when(() => mockAiClient.sendMessage(
        message: any(named: 'message'),
        systemPrompt: any(named: 'systemPrompt'),
        history: any(named: 'history'),
      )).thenAnswer((_) async => expectedResponse);

      when(() => mockDb.saveSummary(any())).thenAnswer((_) async => 1);

      final result = await notifier.executeAction('explain', testText);

      expect(result, equals(expectedResponse));
      expect(notifier.state.result, equals(expectedResponse));
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.currentAction, equals('explain'));
    });

    test('should set loading state while executing', () async {
      when(() => mockAiClient.sendMessage(
        message: any(named: 'message'),
        systemPrompt: any(named: 'systemPrompt'),
        history: any(named: 'history'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return expectedResponse;
      });

      when(() => mockDb.saveSummary(any())).thenAnswer((_) async => 1);

      final future = notifier.executeAction('explain', testText);
      expect(notifier.state.isLoading, isTrue);
      await future;
      expect(notifier.state.isLoading, isFalse);
    });

    test('should handle errors', () async {
      when(() => mockAiClient.sendMessage(
        message: any(named: 'message'),
        systemPrompt: any(named: 'systemPrompt'),
        history: any(named: 'history'),
      )).thenThrow(Exception('API Error'));

      final result = await notifier.executeAction('explain', testText);

      expect(result, isNull);
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.isLoading, isFalse);
    });

    test('should build correct prompts for different action types', () async {
      String? capturedPrompt;

      when(() => mockAiClient.sendMessage(
        message: any(named: 'message'),
        systemPrompt: any(named: 'systemPrompt'),
        history: any(named: 'history'),
      )).thenAnswer((invocation) async {
        capturedPrompt = invocation.namedArguments[#message] as String?;
        return 'response';
      });

      await notifier.executeAction('simplify', testText);
      expect(capturedPrompt, contains('simple English'));
    });

    test('should clear result correctly', () {
      notifier = ReadingActionsNotifier(mockAiClient, mockDb);
      notifier.clearResult();
      expect(notifier.state.result, isNull);
      expect(notifier.state.error, isNull);
    });
  });
}
