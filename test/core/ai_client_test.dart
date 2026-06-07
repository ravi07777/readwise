import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:readwise_ai_assistant/core/network/ai_client.dart';
import 'package:readwise_ai_assistant/core/services/secure_storage_service.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorageService mockStorage;
  late AIClient aiClient;

  setUp(() {
    mockStorage = MockSecureStorageService();
    aiClient = AIClient(storage: mockStorage);
  });

  group('AIClient', () {
    test('should throw when API key is missing', () async {
      when(() => mockStorage.getApiKey(any())).thenAnswer((_) async => null);

      expect(
        () => aiClient.sendMessage(message: 'test'),
        throwsA(isA<Exception>()),
      );
    });

    test('should have default config', () {
      expect(aiClient.config.provider, equals(AIProvider.openAI));
      expect(aiClient.config.model, equals('gpt-4o'));
      expect(aiClient.config.temperature, equals(0.7));
      expect(aiClient.config.maxTokens, equals(4096));
    });

    test('should update config correctly', () {
      final newConfig = const AIProviderConfig(
        provider: AIProvider.gemini,
        model: 'gemini-1.5-pro',
        temperature: 0.5,
        maxTokens: 2048,
      );

      aiClient.updateConfig(newConfig);
      expect(aiClient.config.provider, equals(AIProvider.gemini));
      expect(aiClient.config.model, equals('gemini-1.5-pro'));
      expect(aiClient.config.temperature, equals(0.5));
      expect(aiClient.config.maxTokens, equals(2048));
    });

    test('AIProviderConfig should serialize/deserialize correctly', () {
      const config = AIProviderConfig(
        provider: AIProvider.groq,
        model: 'llama-3.1-70b-versatile',
        temperature: 0.3,
        maxTokens: 8192,
      );

      final json = config.toJson();
      final deserialized = AIProviderConfig.fromJson(json);

      expect(deserialized.provider, equals(config.provider));
      expect(deserialized.model, equals(config.model));
      expect(deserialized.temperature, equals(config.temperature));
      expect(deserialized.maxTokens, equals(config.maxTokens));
    });

    test('AIProvider displayName should be correct', () {
      expect(AIProvider.openAI.displayName, equals('OpenAI'));
      expect(AIProvider.gemini.displayName, equals('Gemini'));
      expect(AIProvider.anthropic.displayName, equals('Anthropic'));
      expect(AIProvider.openRouter.displayName, equals('OpenRouter'));
      expect(AIProvider.groq.displayName, equals('Groq'));
      expect(AIProvider.deepSeek.displayName, equals('DeepSeek'));
      expect(AIProvider.ollama.displayName, equals('Ollama'));
      expect(AIProvider.custom.displayName, equals('Custom'));
    });

    test('AIProvider default models should be non-empty', () {
      for (final provider in AIProvider.values) {
        expect(provider.defaultModel.isNotEmpty, isTrue);
      }
    });
  });
}
