import 'package:flutter_test/flutter_test.dart';
import 'package:readwise_ai_assistant/shared/models/isar_models.dart';

void main() {
  group('Prompt model', () {
    test('should create prompt with default values', () {
      final prompt = Prompt(
        title: 'Test Prompt',
        content: 'Test content {text}',
      );

      expect(prompt.title, equals('Test Prompt'));
      expect(prompt.content, equals('Test content {text}'));
      expect(prompt.isFavorite, isFalse);
      expect(prompt.isBuiltIn, isFalse);
      expect(prompt.isDefault, isFalse);
      expect(prompt.tags, isEmpty);
    });

    test('should create prompt with all fields', () {
      final prompt = Prompt(
        title: 'Complex Prompt',
        content: 'Analyze this text: {text}',
        category: 'Academic',
        tags: ['analysis', 'academic'],
        isFavorite: true,
        isDefault: true,
        isBuiltIn: true,
        sortOrder: 5,
      );

      expect(prompt.title, equals('Complex Prompt'));
      expect(prompt.category, equals('Academic'));
      expect(prompt.tags, containsAll(['analysis', 'academic']));
      expect(prompt.isFavorite, isTrue);
      expect(prompt.isBuiltIn, isTrue);
      expect(prompt.sortOrder, equals(5));
    });

    test('built-in prompts should have correct properties', () {
      final builtInPrompts = [
        Prompt(
          title: 'Simplify English',
          content: 'Rewrite in simple English: {text}',
          category: 'Reading',
          tags: ['simplify'],
          isBuiltIn: true,
          sortOrder: 1,
        ),
        Prompt(
          title: 'Summarize',
          content: 'Summarize: {text}',
          category: 'Summary',
          tags: ['summarize'],
          isBuiltIn: true,
          sortOrder: 2,
        ),
      ];

      for (final prompt in builtInPrompts) {
        expect(prompt.isBuiltIn, isTrue);
        expect(prompt.content.contains('{text}'), isTrue);
      }
    });

    test('should serialize prompt correctly', () {
      final prompt = Prompt(
        title: 'Test',
        content: 'Content {text}',
        category: 'General',
        tags: ['tag1', 'tag2'],
        isFavorite: true,
      );

      expect(prompt.title, isNotEmpty);
      expect(prompt.content, isNotEmpty);
    });
  });
}
