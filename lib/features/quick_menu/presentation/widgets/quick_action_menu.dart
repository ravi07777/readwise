import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/platform_channel_service.dart';
import '../../../../core/services/accessibility_service.dart';
import '../../../../core/network/ai_client.dart';
import '../../../reading_chat/presentation/screens/reading_chat_screen.dart';
import '../../../overlay_response/presentation/widgets/overlay_response_card.dart';

class QuickActionMenu extends ConsumerStatefulWidget {
  const QuickActionMenu({super.key});

  @override
  ConsumerState<QuickActionMenu> createState() => _QuickActionMenuState();
}

class _QuickActionMenuState extends ConsumerState<QuickActionMenu> {
  bool _isLoading = false;
  String? _acquiredText;

  @override
  void initState() {
    super.initState();
    _acquireText();
  }

  Future<void> _acquireText() async {
    setState(() => _isLoading = true);

    try {
      final accessibility = ref.read(accessibilityServiceProvider);
      final platform = ref.read(platformChannelServiceProvider);

      // Priority 1: Selected text
      String? text = await accessibility.getSelectedText();

      // Priority 2: Clipboard text
      if (text == null || text.isEmpty) {
        text = await platform.getClipboardText();
      }

      if (mounted) {
        setState(() {
          _acquiredText = text;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_stories, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ReadWise AI',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            if (_acquiredText != null)
                              Text(
                                '${_acquiredText!.length} characters detected',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Flexible(
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      children: [
                        _buildActionItem(
                          icon: Icons.camera_alt_outlined,
                          title: 'Capture Screen',
                          subtitle: 'Take a screenshot and run OCR',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.pop(context);
                            _handleCaptureScreen();
                          },
                        ),
                        _buildActionItem(
                          icon: Icons.crop_outlined,
                          title: 'Select Screen Region',
                          subtitle: 'Select a specific area to OCR',
                          color: Colors.indigo,
                          onTap: () {
                            Navigator.pop(context);
                            _handleRegionOCR();
                          },
                        ),
                        _buildActionItem(
                          icon: Icons.content_paste_outlined,
                          title: 'Paste Copied Text',
                          subtitle: 'Use text from clipboard',
                          color: Colors.teal,
                          onTap: () {
                            Navigator.pop(context);
                            _handlePasteClipboard();
                          },
                        ),
                        const Divider(height: 1),
                        _buildActionItem(
                          icon: Icons.explore_outlined,
                          title: 'Explain',
                          subtitle: 'Explain this text in detail',
                          color: colorScheme.primary,
                          onTap: () => _handleAction('explain'),
                        ),
                        _buildActionItem(
                          icon: Icons.summarize_outlined,
                          title: 'Summarize',
                          subtitle: 'Get a concise summary',
                          color: Colors.orange,
                          onTap: () => _handleAction('summarize'),
                        ),
                        _buildActionItem(
                          icon: Icons.translate_outlined,
                          title: 'Translate',
                          subtitle: 'Translate to another language',
                          color: Colors.blue,
                          onTap: () => _handleAction('translate'),
                        ),
                        _buildActionItem(
                          icon: Icons.auto_fix_high_outlined,
                          title: 'Simplify English',
                          subtitle: 'Make it easier to understand',
                          color: Colors.green,
                          onTap: () => _handleAction('simplify'),
                        ),
                        _buildActionItem(
                          icon: Icons.menu_book_outlined,
                          title: 'Generate Notes',
                          subtitle: 'Create study notes',
                          color: Colors.brown,
                          onTap: () => _handleAction('notes'),
                        ),
                        _buildActionItem(
                          icon: Icons.quiz_outlined,
                          title: 'Ask AI Question',
                          subtitle: 'Ask anything about the text',
                          color: Colors.pink,
                          onTap: () {
                            Navigator.pop(context);
                            _handleAskQuestion();
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
      dense: true,
    );
  }

  Future<void> _handleAction(String actionType) async {
    if (_acquiredText == null || _acquiredText!.isEmpty) return;

    HapticFeedback.mediumImpact();

    final aiClient = ref.read(aiClientProvider);
    final chat = ref.read(chatProvider.notifier);
    chat.setCurrentText(_acquiredText!);

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: const Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    try {
      final actionPrompts = {
        'explain': 'Explain the following text in detail:\n\n${_acquiredText!}',
        'summarize': 'Provide a concise summary of:\n\n${_acquiredText!}',
        'translate': 'Translate the following text to Hindi:\n\n${_acquiredText!}',
        'simplify': 'Rewrite in simple English:\n\n${_acquiredText!}',
        'notes': 'Create study notes from:\n\n${_acquiredText!}',
      };

      final response = await aiClient.sendMessage(
        message: actionPrompts[actionType] ?? _acquiredText!,
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loader
        chat.sendWithAction(_acquiredText!, actionType);
        _showResponseCard(actionType, response);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showResponseCard(String actionType, String response) {
    final titles = {
      'explain': 'Explanation',
      'summarize': 'Summary',
      'translate': 'Translation',
      'simplify': 'Simplified Text',
      'notes': 'Study Notes',
    };

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Center(
        child: OverlayResponseCard(
          title: titles[actionType] ?? 'Response',
          content: response,
          sourceText: _acquiredText,
          actionType: actionType,
          onClose: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  void _handleCaptureScreen() {
    // Trigger screen capture via platform channel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Screen capture triggered')),
    );
  }

  void _handleRegionOCR() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Select a region on screen')),
    );
  }

  Future<void> _handlePasteClipboard() async {
    final platform = ref.read(platformChannelServiceProvider);
    final text = await platform.getClipboardText();
    if (text != null && text.isNotEmpty) {
      setState(() => _acquiredText = text);
    }
  }

  void _handleAskQuestion() {
    final chat = ref.read(chatProvider.notifier);
    if (_acquiredText != null) {
      chat.setCurrentText(_acquiredText!);
    }
    Navigator.pop(context);
  }
}
