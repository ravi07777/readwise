import 'package:isar/isar.dart';

part 'isar_models.g.dart';

@collection
class Prompt {
  Id id = Isar.autoIncrement;
  late String title;
  late String content;
  late String? category;
  late List<String> tags;
  late bool isFavorite;
  late bool isDefault;
  late bool isBuiltIn;
  late int sortOrder;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Prompt({
    this.title = '',
    this.content = '',
    this.category,
    this.tags = const [],
    this.isFavorite = false,
    this.isDefault = false,
    this.isBuiltIn = false,
    this.sortOrder = 0,
  });
}

@collection
class Note {
  Id id = Isar.autoIncrement;
  late String title;
  late String content;
  late String? sourceText;
  late String? sessionId;
  late String? conversationId;
  late List<String> tags;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Note({
    this.title = '',
    this.content = '',
    this.sourceText,
    this.sessionId,
    this.conversationId,
    this.tags = const [],
  });
}

@collection
class Flashcard {
  Id id = Isar.autoIncrement;
  late String question;
  late String answer;
  late String? sourceText;
  late String? sessionId;
  late String? category;
  late int difficulty;
  late int interval;
  late int reviewCount;
  late DateTime? lastReviewedDate;
  late DateTime? nextReviewDate;
  DateTime createdAt = DateTime.now();

  Flashcard({
    this.question = '',
    this.answer = '',
    this.sourceText,
    this.sessionId,
    this.category,
    this.difficulty = 0,
    this.interval = 0,
    this.reviewCount = 0,
    this.lastReviewedDate,
  });
}

@collection
class ReadingSession {
  Id id = Isar.autoIncrement;
  late String source;
  late String? title;
  late String? author;
  late String? url;
  late String? appName;
  late String? lastText;
  late int totalCharacters;
  late int totalPages;
  late int currentPage;
  DateTime startedAt = DateTime.now();
  late DateTime? endedAt;
  late bool isActive;

  ReadingSession({
    this.source = '',
    this.title,
    this.author,
    this.url,
    this.appName,
    this.lastText,
    this.totalCharacters = 0,
    this.totalPages = 0,
    this.currentPage = 0,
    this.endedAt,
    this.isActive = true,
  });
}

@collection
class Conversation {
  Id id = Isar.autoIncrement;
  late String title;
  late String? sourceText;
  late String? sessionId;
  late String? modelUsed;
  late int messageCount;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Conversation({
    this.title = 'New Conversation',
    this.sourceText,
    this.sessionId,
    this.modelUsed,
    this.messageCount = 0,
  });
}

@collection
class Message {
  Id id = Isar.autoIncrement;
  late int conversationId;
  late String role;
  late String content;
  late String? actionType;
  late String? providerUsed;
  late int tokensUsed;
  DateTime createdAt = DateTime.now();

  Message({
    this.conversationId = 0,
    this.role = 'user',
    this.content = '',
    this.actionType,
    this.providerUsed,
    this.tokensUsed = 0,
  });
}

@collection
class VocabularyWord {
  Id id = Isar.autoIncrement;
  late String word;
  late String? definition;
  late String? exampleSentence;
  late String? sourceText;
  late String? sessionId;
  late String? language;
  late bool isKnown;
  late int reviewCount;
  late int interval;
  late DateTime? nextReviewDate;
  late DateTime? lastSeenDate;
  DateTime createdAt = DateTime.now();

  VocabularyWord({
    this.word = '',
    this.definition,
    this.exampleSentence,
    this.sourceText,
    this.sessionId,
    this.language = 'en',
    this.isKnown = false,
    this.reviewCount = 0,
    this.interval = 0,
    this.lastSeenDate,
  });
}

@collection
class Phrase {
  Id id = Isar.autoIncrement;
  late String phrase;
  late String? meaning;
  late String? exampleSentence;
  late String? sourceText;
  late String? sessionId;
  late String? language;
  late bool isSaved;
  DateTime createdAt = DateTime.now();

  Phrase({
    this.phrase = '',
    this.meaning,
    this.exampleSentence,
    this.sourceText,
    this.sessionId,
    this.language = 'en',
    this.isSaved = false,
  });
}

@collection
class Idiom {
  Id id = Isar.autoIncrement;
  late String idiom;
  late String? meaning;
  late String? exampleSentence;
  late String? literalMeaning;
  late String? origin;
  late String? sourceText;
  late String? sessionId;
  late bool isSaved;
  DateTime createdAt = DateTime.now();

  Idiom({
    this.idiom = '',
    this.meaning,
    this.exampleSentence,
    this.literalMeaning,
    this.origin,
    this.sourceText,
    this.sessionId,
    this.isSaved = false,
  });
}

@collection
class Summary {
  Id id = Isar.autoIncrement;
  late String title;
  late String content;
  late String? sourceText;
  late String? sessionId;
  late String? type;
  late int characterCount;
  DateTime createdAt = DateTime.now();

  Summary({
    this.title = '',
    this.content = '',
    this.sourceText,
    this.sessionId,
    this.type = 'page',
    this.characterCount = 0,
  });
}

@collection
class Bookmark {
  Id id = Isar.autoIncrement;
  late String title;
  late String? note;
  late String? sourceText;
  late String? sessionId;
  late String? pageReference;
  DateTime createdAt = DateTime.now();

  Bookmark({
    this.title = '',
    this.note,
    this.sourceText,
    this.sessionId,
    this.pageReference,
  });
}

@collection
class ReadingHighlight {
  Id id = Isar.autoIncrement;
  late String text;
  late String? note;
  late String? color;
  late String? sessionId;
  late String? source;
  DateTime createdAt = DateTime.now();

  ReadingHighlight({
    this.text = '',
    this.note,
    this.color = 'yellow',
    this.sessionId,
    this.source,
  });
}
