import 'dart:io';
import 'package:flutter/foundation.dart' hide Summary;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../shared/models/isar_models.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  late Isar _isar;
  bool _initialized = false;

  Isar get isar => _isar;

  Future<void> initialize() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    final isarDir = Directory('${dir.path}/readwise_db');
    if (!isarDir.existsSync()) {
      await isarDir.create(recursive: true);
    }

    _isar = await Isar.open(
      [
        PromptSchema,
        NoteSchema,
        FlashcardSchema,
        ReadingSessionSchema,
        ConversationSchema,
        MessageSchema,
        VocabularyWordSchema,
        PhraseSchema,
        IdiomSchema,
        TextSummarySchema,
        BookmarkSchema,
        ReadingHighlightSchema,
      ],
      directory: isarDir.path,
      inspector: kDebugMode,
    );

    _initialized = true;
  }

  Future<void> close() async {
    await _isar.close();
  }

  // Prompt operations
  Future<int> savePrompt(Prompt prompt) => _isar.writeTxn(() => _isar.prompts.put(prompt));
  Future<Prompt?> getPrompt(int id) => _isar.prompts.get(id);
  Future<List<Prompt>> getAllPrompts() => _isar.prompts.where().findAll();
  Future<List<Prompt>> getFavoritePrompts() => _isar.prompts.where().filter().isFavoriteEqualTo(true).findAll();
  Future<List<Prompt>> getPromptsByCategory(String category) =>
      _isar.prompts.where().filter().categoryEqualTo(category).findAll();
  Future<List<Prompt>> getPromptsByTag(String tag) =>
      _isar.prompts.where().filter().tagsElementEqualTo(tag).findAll();
  Future<void> deletePrompt(int id) => _isar.writeTxn(() => _isar.prompts.delete(id));
  Future<void> deletePrompts(List<int> ids) => _isar.writeTxn(() => _isar.prompts.deleteAll(ids));

  // Note operations
  Future<int> saveNote(Note note) => _isar.writeTxn(() => _isar.notes.put(note));
  Future<Note?> getNote(int id) => _isar.notes.get(id);
  Future<List<Note>> getAllNotes() => _isar.notes.where().findAll();
  Future<List<Note>> getNotesBySession(String sessionId) =>
      _isar.notes.where().filter().sessionIdEqualTo(sessionId).findAll();
  Future<void> deleteNote(int id) => _isar.writeTxn(() => _isar.notes.delete(id));

  // Flashcard operations
  Future<int> saveFlashcard(Flashcard flashcard) =>
      _isar.writeTxn(() => _isar.flashcards.put(flashcard));
  Future<Flashcard?> getFlashcard(int id) => _isar.flashcards.get(id);
  Future<List<Flashcard>> getAllFlashcards() => _isar.flashcards.where().findAll();
  Future<List<Flashcard>> getFlashcardsForReview() =>
      _isar.flashcards.where().filter().nextReviewDateLessThan(DateTime.now()).findAll();
  Future<List<Flashcard>> getFlashcardsByDifficulty(int difficulty) =>
      _isar.flashcards.where().filter().difficultyEqualTo(difficulty).findAll();
  Future<void> deleteFlashcard(int id) => _isar.writeTxn(() => _isar.flashcards.delete(id));
  Future<void> updateFlashcardReview(int id, int difficulty, int interval, DateTime nextReview) =>
      _isar.writeTxn(() async {
        final card = await _isar.flashcards.get(id);
        if (card != null) {
          card.difficulty = difficulty;
          card.interval = interval;
          card.nextReviewDate = nextReview;
          card.lastReviewedDate = DateTime.now();
          card.reviewCount += 1;
          await _isar.flashcards.put(card);
        }
      });

  // Reading session operations
  Future<int> saveReadingSession(ReadingSession session) =>
      _isar.writeTxn(() => _isar.readingSessions.put(session));
  Future<ReadingSession?> getReadingSession(int id) => _isar.readingSessions.get(id);
  Future<List<ReadingSession>> getAllReadingSessions() => _isar.readingSessions.where().findAll();
  Future<List<ReadingSession>> getRecentSessions({int limit = 10}) =>
      _isar.readingSessions.where().sortByStartedAtDesc().limit(limit).findAll();
  Future<void> deleteReadingSession(int id) =>
      _isar.writeTxn(() => _isar.readingSessions.delete(id));

  // Conversation operations
  Future<int> saveConversation(Conversation conversation) =>
      _isar.writeTxn(() => _isar.conversations.put(conversation));
  Future<Conversation?> getConversation(int id) => _isar.conversations.get(id);
  Future<List<Conversation>> getAllConversations() => _isar.conversations.where().findAll();
  Future<List<Conversation>> getRecentConversations({int limit = 20}) =>
      _isar.conversations.where().sortByUpdatedAtDesc().limit(limit).findAll();
  Future<void> deleteConversation(int id) =>
      _isar.writeTxn(() => _isar.conversations.delete(id));

  // Message operations
  Future<int> saveMessage(Message message) =>
      _isar.writeTxn(() => _isar.messages.put(message));
  Future<List<Message>> getMessagesForConversation(int conversationId) async {
    final messages = await _isar.messages.filter().conversationIdEqualTo(conversationId).findAll();
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }
  Future<void> deleteMessagesForConversation(int conversationId) =>
      _isar.writeTxn(() => _isar.messages.where().filter().conversationIdEqualTo(conversationId).deleteAll());

  // Vocabulary operations
  Future<int> saveVocabularyWord(VocabularyWord word) =>
      _isar.writeTxn(() => _isar.vocabularyWords.put(word));
  Future<VocabularyWord?> getVocabularyWord(int id) => _isar.vocabularyWords.get(id);
  Future<VocabularyWord?> getVocabularyWordByText(String word) =>
      _isar.vocabularyWords.where().filter().wordEqualTo(word).findFirst();
  Future<List<VocabularyWord>> getAllVocabularyWords() => _isar.vocabularyWords.where().findAll();
  Future<List<VocabularyWord>> getUnknownWords() =>
      _isar.vocabularyWords.where().filter().isKnownEqualTo(false).findAll();
  Future<List<VocabularyWord>> getWordsForReview() =>
      _isar.vocabularyWords.where().filter().nextReviewDateLessThan(DateTime.now()).findAll();
  Future<void> deleteVocabularyWord(int id) =>
      _isar.writeTxn(() => _isar.vocabularyWords.delete(id));

  // Phrase operations
  Future<int> savePhrase(Phrase phrase) =>
      _isar.writeTxn(() => _isar.phrases.put(phrase));
  Future<Phrase?> getPhrase(int id) => _isar.phrases.get(id);
  Future<List<Phrase>> getAllPhrases() => _isar.phrases.where().findAll();
  Future<void> deletePhrase(int id) => _isar.writeTxn(() => _isar.phrases.delete(id));

  // Idiom operations
  Future<int> saveIdiom(Idiom idiom) => _isar.writeTxn(() => _isar.idioms.put(idiom));
  Future<Idiom?> getIdiom(int id) => _isar.idioms.get(id);
  Future<List<Idiom>> getAllIdioms() => _isar.idioms.where().findAll();
  Future<void> deleteIdiom(int id) => _isar.writeTxn(() => _isar.idioms.delete(id));

  // Summary operations
  Future<int> saveSummary(TextSummary summary) =>
      _isar.writeTxn(() => _isar.summaries.put(summary));
  Future<TextSummary?> getSummary(int id) => _isar.summaries.get(id);
  Future<List<TextSummary>> getAllSummaries() => _isar.summaries.where().findAll();
  Future<List<TextSummary>> getSummariesBySession(String sessionId) =>
      _isar.summaries.where().filter().sessionIdEqualTo(sessionId).findAll();
  Future<void> deleteSummary(int id) => _isar.writeTxn(() => _isar.summaries.delete(id));

  // Bookmark operations
  Future<int> saveBookmark(Bookmark bookmark) =>
      _isar.writeTxn(() => _isar.bookmarks.put(bookmark));
  Future<Bookmark?> getBookmark(int id) => _isar.bookmarks.get(id);
  Future<List<Bookmark>> getAllBookmarks() => _isar.bookmarks.where().findAll();
  Future<void> deleteBookmark(int id) => _isar.writeTxn(() => _isar.bookmarks.delete(id));

  // Highlight operations
  Future<int> saveHighlight(ReadingHighlight highlight) =>
      _isar.writeTxn(() => _isar.readingHighlights.put(highlight));
  Future<List<ReadingHighlight>> getAllHighlights() => _isar.readingHighlights.where().findAll();
  Future<void> deleteHighlight(int id) =>
      _isar.writeTxn(() => _isar.readingHighlights.delete(id));
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});
