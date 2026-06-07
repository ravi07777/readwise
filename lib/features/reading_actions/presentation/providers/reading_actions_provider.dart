import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/ai_client.dart';
import '../../../../core/database/database_service.dart';
import '../../../reading_chat/presentation/screens/reading_chat_screen.dart';

class ReadingActionsState {
  final bool isLoading;
  final String? result;
  final String? error;
  final String? currentAction;

  const ReadingActionsState({
    this.isLoading = false,
    this.result,
    this.error,
    this.currentAction,
  });

  ReadingActionsState copyWith({
    bool? isLoading,
    String? result,
    String? error,
    String? currentAction,
  }) {
    return ReadingActionsState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
      currentAction: currentAction ?? this.currentAction,
    );
  }
}

final readingActionsProvider =
    StateNotifierProvider<ReadingActionsNotifier, ReadingActionsState>((ref) {
  return ReadingActionsNotifier(
    ref.watch(aiClientProvider),
    ref.watch(databaseServiceProvider),
  );
});

class ReadingActionsNotifier extends StateNotifier<ReadingActionsState> {
  final AIClient _aiClient;
  final DatabaseService _db;

  ReadingActionsNotifier(this._aiClient, this._db)
      : super(const ReadingActionsState());

  Future<String?> executeAction(String action, String text) async {
    state = state.copyWith(isLoading: true, error: null, currentAction: action);

    try {
      final prompt = _buildActionPrompt(action, text);
      final response = await _aiClient.sendMessage(message: prompt);

      state = state.copyWith(isLoading: false, result: response);
      await _saveActionResult(action, text, response);
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  String _buildActionPrompt(String action, String text) {
    switch (action) {
      // Explain variants
      case 'explain':
        return 'Explain the following text in detail. Break down complex ideas, define difficult terms, and provide context:\n\n$text';
      case 'explain_beginner':
        return 'Explain the following text as if I am a complete beginner. Use very simple words, analogies, and examples:\n\n$text';
      case 'explain_teacher':
        return 'Explain the following text as if you are a knowledgeable teacher. Break down complex ideas step by step:\n\n$text';
      case 'explain_professor':
        return 'Provide a scholarly analysis of the following text. Discuss context, implications, and significance:\n\n$text';

      // Language
      case 'simplify':
        return 'Rewrite the following text in simple, easy-to-understand English. Use short sentences and common words:\n\n$text';
      case 'translate':
        return 'Translate the following text to English:\n\n$text';
      case 'translate_hindi':
        return 'Translate the following text to Hindi. Preserve the meaning and tone:\n\n$text';
      case 'translate_urdu':
        return 'Translate the following text to Urdu. Preserve the meaning and tone:\n\n$text';
      case 'translate_hinglish':
        return 'Translate the following text to Hinglish (Hindi + English mix):\n\n$text';

      // Word/Phrase/Idiom
      case 'define_word':
        return 'Define the following word. Include pronunciation, part of speech, definition, example sentence, synonyms, and antonyms:\n\n$text';
      case 'explain_phrase':
        return 'Explain the following phrase. Include its meaning, usage, and context:\n\n$text';
      case 'explain_idiom':
        return 'Explain the following idiom. Include its literal meaning, actual meaning, origin, and usage example:\n\n$text';
      case 'explain_sentence':
        return 'Explain the following sentence. Break down its grammar, meaning, and context:\n\n$text';

      // Summary
      case 'summarize':
        return 'Provide a concise summary of the following text. Include main points and key takeaways:\n\n$text';
      case 'summarize_paragraph':
        return 'Summarize this paragraph in 1-2 sentences:\n\n$text';
      case 'summarize_chapter':
        return 'Summarize this chapter/section. Include main themes, key arguments, and conclusions:\n\n$text';
      case 'summarize_page':
        return 'Summarize this page. Include the main topic and key points:\n\n$text';
      case 'conclusion':
        return 'What is the main conclusion of the following text?:\n\n$text';
      case 'main_argument':
        return 'What is the main argument or thesis of the following text?:\n\n$text';
      case 'key_takeaways':
        return 'List the key takeaways from the following text as bullet points:\n\n$text';

      // Learning
      case 'generate_notes':
        return 'Create comprehensive study notes from the following text. Use headings, bullet points, and organized sections:\n\n$text';
      case 'generate_flashcards':
        return 'Create flashcards from the following text. Format as question/answer pairs:\n\n$text';
      case 'generate_quiz':
        return 'Create a quiz with multiple choice and short answer questions from the following text. Provide answers:\n\n$text';

      // Professional
      case 'research_paper':
        return 'Analyze this research text. Provide: methodology, findings, limitations, and significance:\n\n$text';
      case 'academic_simplifier':
        return 'Simplify this academic text for easier understanding. Explain technical terms:\n\n$text';
      case 'legal_simplifier':
        return 'Simplify this legal text for a non-lawyer. Explain legal terms and implications:\n\n$text';
      case 'medical_simplifier':
        return 'Simplify this medical text for a patient. Explain medical terms clearly:\n\n$text';

      // Discussion & Coaching
      case 'book_discussion':
        return 'Engage in a discussion about this text. Ask thoughtful questions:\n\n$text';
      case 'reading_coach':
        return 'Act as a reading coach. Help me understand this text better:\n\n$text';
      case 'vocabulary_builder':
        return 'Identify difficult words in this text. For each, provide definition, pronunciation, and example:\n\n$text';

      default:
        return text;
    }
  }

  Future<void> _saveActionResult(String action, String text, String response) async {
    try {
      if (action == 'generate_notes') {
        await _db.saveNote(Note(
          title: 'Reading Notes - ${DateTime.now().toString().substring(0, 10)}',
          content: response,
          sourceText: text,
        ));
      } else if (action == 'summarize' || action.startsWith('summarize')) {
        await _db.saveSummary(TextSummary(
          title: 'Summary - ${action.replaceFirst('summarize', '')}',
          content: response,
          sourceText: text,
        ));
      }
    } catch (e) {
      // Silently fail for non-critical saves
    }
  }

  void clearResult() {
    state = const ReadingActionsState();
  }
}
