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
  late DateTime createdAt;
  late DateTime updatedAt;

  Prompt({
    this.title = '',
    this.content = '',
    this.category,
    this.tags = const [],
    this.isFavorite = false,
    this.isDefault = false,
    this.isBuiltIn = false,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
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
  late DateTime createdAt;
  late DateTime updatedAt;

  Note({
    this.title = '',
    this.content = '',
    this.sourceText,
    this.sessionId,
    this.conversationId,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
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
  late DateTime createdAt;

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
    DateTime? nextReviewDate,
    DateTime? createdAt,
  })  : nextReviewDate = nextReviewDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();
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
  late DateTime startedAt;
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
    DateTime? startedAt,
    this.endedAt,
    this.isActive = true,
  }) : startedAt = startedAt ?? DateTime.now();
}

@collection
class Conversation {
  Id id = Isar.autoIncrement;
  late String title;
  late String? sourceText;
  late String? sessionId;
  late String? modelUsed;
  late int messageCount;
  late DateTime createdAt;
  late DateTime updatedAt;

  Conversation({
    this.title = 'New Conversation',
    this.sourceText,
    this.sessionId,
    this.modelUsed,
    this.messageCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
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
  late DateTime createdAt;

  Message({
    this.conversationId = 0,
    this.role = 'user',
    this.content = '',
    this.actionType,
    this.providerUsed,
    this.tokensUsed = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
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
  late DateTime createdAt;

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
    DateTime? nextReviewDate,
    this.lastSeenDate,
    DateTime? createdAt,
  })  : nextReviewDate = nextReviewDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();
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
  late DateTime createdAt;

  Phrase({
    this.phrase = '',
    this.meaning,
    this.exampleSentence,
    this.sourceText,
    this.sessionId,
    this.language = 'en',
    this.isSaved = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
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
  late DateTime createdAt;

  Idiom({
    this.idiom = '',
    this.meaning,
    this.exampleSentence,
    this.literalMeaning,
    this.origin,
    this.sourceText,
    this.sessionId,
    this.isSaved = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
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
  late DateTime createdAt;

  Summary({
    this.title = '',
    this.content = '',
    this.sourceText,
    this.sessionId,
    this.type = 'page',
    this.characterCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

@collection
class Bookmark {
  Id id = Isar.autoIncrement;
  late String title;
  late String? note;
  late String? sourceText;
  late String? sessionId;
  late String? pageReference;
  late DateTime createdAt;

  Bookmark({
    this.title = '',
    this.note,
    this.sourceText,
    this.sessionId,
    this.pageReference,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

@collection
class ReadingHighlight {
  Id id = Isar.autoIncrement;
  late String text;
  late String? note;
  late String? color;
  late String? sessionId;
  late String? source;
  late DateTime createdAt;

  ReadingHighlight({
    this.text = '',
    this.note,
    this.color = 'yellow',
    this.sessionId,
    this.source,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
