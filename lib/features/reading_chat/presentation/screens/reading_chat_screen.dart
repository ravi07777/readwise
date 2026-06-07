import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/accessibility_service.dart';
import '../../../../core/services/platform_channel_service.dart';
import '../../../../core/network/ai_client.dart';
import '../../../../shared/providers/settings_provider.dart';
import '../../../../shared/models/isar_models.dart';
import '../../../../core/database/database_service.dart';
import '../../../overlay_response/presentation/widgets/overlay_response_card.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref.watch(aiClientProvider),
    ref.watch(databaseServiceProvider),
    ref.watch(secureStorageServiceProvider),
  );
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final bool isListening;
  final String currentText;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isListening = false,
    this.currentText = '',
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool? isListening,
    String? currentText,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isListening: isListening ?? this.isListening,
      currentText: currentText ?? this.currentText,
    );
  }
}

class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;
  final String? actionType;

  const ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.actionType,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatNotifier extends StateNotifier<ChatState> {
  final AIClient _aiClient;
  final DatabaseService _db;
  final SecureStorageService _storage;

  ChatNotifier(this._aiClient, this._db, this._storage) : super(const ChatState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(role: 'user', content: text);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final history = state.messages
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final systemPrompt = await _getSystemPrompt();
      String response;

      if (state.currentText.isNotEmpty) {
        final contextPrompt = '''
Context from current reading:
${state.currentText}

User question: $text

Please answer based on the reading context above.
''';
        response = await _aiClient.sendMessage(
          message: contextPrompt,
          systemPrompt: systemPrompt,
          history: history,
        );
      } else {
        response = await _aiClient.sendMessage(
          message: text,
          systemPrompt: systemPrompt,
          history: history,
        );
      }

      final aiMessage = ChatMessage(role: 'assistant', content: response);
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );

      await _saveConversation(text, response);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendWithAction(String text, String actionType) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      role: 'user',
      content: text,
      actionType: actionType,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final actionPrompt = _getActionPrompt(actionType, text);
      final response = await _aiClient.sendMessage(
        message: actionPrompt,
        systemPrompt: await _getSystemPrompt(),
      );

      final aiMessage = ChatMessage(
        role: 'assistant',
        content: response,
        actionType: actionType,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );

      await _saveConversation(text, response);
      await _saveToMemory(text, response, actionType);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendWithStreaming(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(role: 'user', content: text);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    final buffer = StringBuffer();
    final assistantIndex = state.messages.length + 1;

    state = state.copyWith(
      messages: [
        ...state.messages,
        const ChatMessage(role: 'assistant', content: ''),
      ],
    );

    try {
      await _aiClient.sendStreamingMessage(
        message: text,
        systemPrompt: await _getSystemPrompt(),
        onChunk: (chunk) {
          buffer.write(chunk);
          final messages = [...state.messages];
          messages[assistantIndex] = ChatMessage(
            role: 'assistant',
            content: buffer.toString(),
          );
          state = state.copyWith(messages: messages);
        },
      );

      state = state.copyWith(isLoading: false);
      await _saveConversation(text, buffer.toString());
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setCurrentText(String text) {
    state = state.copyWith(currentText: text);
  }

  void clearMessages() {
    state = state.copyWith(messages: [], error: null);
  }

  Future<String> _getSystemPrompt() async {
    final defaultPrompt = await _storage.getString('default_system_prompt');
    return defaultPrompt ?? '''
You are ReadWise AI Assistant, a helpful reading companion.
You help users understand difficult text by providing clear explanations,
simplifications, translations, and insights.
Keep responses concise and focused on the text being read.
''';
  }

  String _getActionPrompt(String action, String text) {
    switch (action) {
      case 'explain':
        return 'Explain the following text in detail:\n\n$text';
      case 'simplify':
        return 'Simplify the following text using simple English:\n\n$text';
      case 'translate':
        return 'Translate the following text to Hindi:\n\n$text';
      case 'summarize':
        return 'Provide a concise summary of the following text:\n\n$text';
      case 'define':
        return 'Define and explain the following word/phrase:\n\n$text';
      case 'idiom':
        return 'Explain the idiom/phrase and its meaning:\n\n$text';
      case 'notes':
        return 'Generate comprehensive study notes from the following text:\n\n$text';
      case 'flashcards':
        return 'Create flashcards from the following text (question/answer pairs):\n\n$text';
      case 'quiz':
        return 'Create a quiz with questions and answers from the following text:\n\n$text';
      case 'discuss':
        return 'Engage in a thoughtful discussion about the following text:\n\n$text';
      default:
        return text;
    }
  }

  Future<void> _saveConversation(String question, String answer) async {
    try {
      final conversation = Conversation(
        title: question.length > 50 ? '${question.substring(0, 50)}...' : question,
        sourceText: state.currentText.isNotEmpty ? state.currentText : null,
        modelUsed: _aiClient.config.model,
        messageCount: state.messages.length,
      );
      final convId = await _db.saveConversation(conversation);

      final userMsg = Message(
        conversationId: convId,
        role: 'user',
        content: question,
      );
      await _db.saveMessage(userMsg);

      final aiMsg = Message(
        conversationId: convId,
        role: 'assistant',
        content: answer,
        providerUsed: _aiClient.config.provider.displayName,
        tokensUsed: answer.length,
      );
      await _db.saveMessage(aiMsg);
    } catch (e) {
      // silently fail - conversation history is non-critical
    }
  }

  Future<void> _saveToMemory(String text, String response, String actionType) async {
    try {
      switch (actionType) {
        case 'notes':
          await _db.saveNote(Note(
            title: 'AI Generated Notes',
            content: response,
            sourceText: text,
          ));
          break;
        case 'flashcards':
          // Parse flashcards from response and save
          break;
        case 'summarize':
          await _db.saveSummary(Summary(
            title: 'AI Summary',
            content: response,
            sourceText: text,
          }));
          break;
      }
    } catch (e) {
      // silently fail
    }
  }
}

class ReadingChatScreen extends ConsumerStatefulWidget {
  const ReadingChatScreen({super.key});

  @override
  ConsumerState<ReadingChatScreen> createState() => _ReadingChatScreenState();
}

class _ReadingChatScreenState extends ConsumerState<ReadingChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _acquireText() async {
    final chat = ref.read(chatProvider.notifier);
    final accessibility = ref.read(accessibilityServiceProvider);
    final platform = ref.read(platformChannelServiceProvider);

    // Try accessibility selected text first
    String? text = await accessibility.getSelectedText();

    // Then try clipboard
    if (text == null || text.isEmpty) {
      text = await platform.getClipboardText();
    }

    if (text != null && text.isNotEmpty) {
      chat.setCurrentText(text);
      _textController.text = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReadWise AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Chat',
            onPressed: () {
              ref.read(chatProvider.notifier).clearMessages();
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_snippet_outlined),
            tooltip: 'Acquire Text',
            onPressed: _acquireText,
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: colorScheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colorScheme.error, size: 18),
                    onPressed: () => ref.read(chatProvider.notifier).state =
                        state.copyWith(error: null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: state.messages.isEmpty
                ? _buildEmptyState(colorScheme)
                : _buildMessagesList(state, colorScheme),
          ),
          if (state.currentText.isNotEmpty)
            _buildCurrentTextChip(colorScheme),
          _buildInputBar(colorScheme, state),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    final quickActions = [
      _QuickAction(icon: Icons.explore_outlined, label: 'Explain', action: 'explain'),
      _QuickAction(icon: Icons.auto_fix_high_outlined, label: 'Simplify', action: 'simplify'),
      _QuickAction(icon: Icons.translate_outlined, label: 'Translate', action: 'translate'),
      _QuickAction(icon: Icons.summarize_outlined, label: 'Summarize', action: 'summarize'),
      _QuickAction(icon: Icons.menu_book_outlined, label: 'Notes', action: 'notes'),
      _QuickAction(icon: Icons.quiz_outlined, label: 'Quiz', action: 'quiz'),
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories,
              size: 72,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'ReadWise AI Assistant',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your AI-powered reading companion\nTap an action or ask a question',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: quickActions.map((action) {
                return ActionChip(
                  avatar: Icon(action.icon, size: 18),
                  label: Text(action.label),
                  onPressed: () {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      ref.read(chatProvider.notifier).sendWithAction(text, action.action);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatState state, ColorScheme colorScheme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isUser = message.role == 'user';

        return Padding(
          padding: EdgeInsets.only(
            bottom: 12,
            left: isUser ? 48 : 0,
            right: isUser ? 0 : 48,
          ),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(
                  isUser ? 20 : 20,
                ).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.actionType != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.actionType!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  SelectableText(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(
                  begin: 0.1,
                  end: 0,
                  curve: Curves.easeOut,
                ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentTextChip(ColorScheme colorScheme) {
    final chat = ref.read(chatProvider.notifier);
    final text = ref.watch(chatProvider).currentText;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.article_outlined, size: 16, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text.length > 60 ? '${text.substring(0, 60)}...' : text,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSecondaryContainer,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => chat.setCurrentText(''),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: colorScheme.onSecondaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ColorScheme colorScheme, ChatState state) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask about what you\'re reading...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: state.isLoading ? null : (value) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: 200.ms,
              child: Material(
                color: state.isLoading
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.primary,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: state.isLoading ? null : _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: state.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          )
                        : Icon(
                            Icons.arrow_upward,
                            color: colorScheme.onPrimary,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String action;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.action,
  });
}
