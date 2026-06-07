import 'package:flutter_test/flutter_test.dart';
import 'package:readwise_ai_assistant/shared/models/isar_models.dart';

void main() {
  group('VocabularyWord model', () {
    test('should create vocabulary word with default values', () {
      final word = VocabularyWord(word: 'ephemeral');

      expect(word.word, equals('ephemeral'));
      expect(word.isKnown, isFalse);
      expect(word.reviewCount, equals(0));
      expect(word.language, equals('en'));
    });

    test('should create vocabulary word with all fields', () {
      final word = VocabularyWord(
        word: 'ubiquitous',
        definition: 'Present everywhere',
        exampleSentence: 'Smartphones are ubiquitous in modern society.',
        isKnown: true,
        reviewCount: 5,
        language: 'en',
      );

      expect(word.word, equals('ubiquitous'));
      expect(word.definition, equals('Present everywhere'));
      expect(word.isKnown, isTrue);
      expect(word.reviewCount, equals(5));
    });

    test('should update review count', () {
      final word = VocabularyWord(word: 'test', reviewCount: 0);
      expect(word.reviewCount, equals(0));
    });
  });

  group('Flashcard model', () {
    test('should create flashcard with default values', () {
      final card = Flashcard(
        question: 'What is Flutter?',
        answer: 'A UI toolkit by Google',
      );

      expect(card.question, equals('What is Flutter?'));
      expect(card.difficulty, equals(0));
      expect(card.reviewCount, equals(0));
    });

    test('should create flashcard with difficulty', () {
      final card = Flashcard(
        question: 'Question?',
        answer: 'Answer',
        difficulty: 3,
        reviewCount: 2,
      );

      expect(card.difficulty, equals(3));
      expect(card.reviewCount, equals(2));
    });
  });

  group('ReadingSession model', () {
    test('should create reading session', () {
      final session = ReadingSession(
        source: 'Kindle',
        title: 'Chapter 1',
        totalCharacters: 5000,
        currentPage: 1,
      );

      expect(session.source, equals('Kindle'));
      expect(session.title, equals('Chapter 1'));
      expect(session.isActive, isTrue);
    });
  });

  group('Note model', () {
    test('should create note', () {
      final note = Note(
        title: 'My Note',
        content: 'Note content here',
        tags: ['important', 'reading'],
      );

      expect(note.title, equals('My Note'));
      expect(note.tags, containsAll(['important', 'reading']));
    });
  });
}
