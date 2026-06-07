import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database_service.dart';
import '../../../../shared/models/isar_models.dart';

class OverlayResponseCard extends ConsumerStatefulWidget {
  final String title;
  final String content;
  final String? sourceText;
  final String? actionType;
  final VoidCallback? onClose;

  const OverlayResponseCard({
    super.key,
    required this.title,
    required this.content,
    this.sourceText,
    this.actionType,
    this.onClose,
  });

  @override
  ConsumerState<OverlayResponseCard> createState() => _OverlayResponseCardState();
}

class _OverlayResponseCardState extends ConsumerState<OverlayResponseCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: 300.ms,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          minWidth: 280,
          maxWidth: 400,
          minHeight: _isExpanded ? 400 : 200,
          maxHeight: _isExpanded ? 500 : 300,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getActionIcon(),
                      color: colorScheme.onPrimary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                        if (_isExpanded) {
                          _animController.forward();
                        } else {
                          _animController.reverse();
                        }
                      });
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                        size: 16,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: widget.onClose ?? () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  widget.content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            // Action buttons
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(Icons.copy, 'Copy', colorScheme, () {
                    Clipboard.setData(ClipboardData(text: widget.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  }),
                  _buildActionButton(Icons.save_outlined, 'Save', colorScheme, _saveContent),
                  _buildActionButton(Icons.share_outlined, 'Share', colorScheme, _shareContent),
                  _buildActionButton(Icons.chat_outlined, 'Follow-up', colorScheme, () {
                    // Open follow-up chat
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildActionButton(IconData icon, String label, ColorScheme colorScheme, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActionIcon() {
    switch (widget.actionType) {
      case 'explain':
        return Icons.explore_outlined;
      case 'simplify':
        return Icons.auto_fix_high_outlined;
      case 'translate':
        return Icons.translate_outlined;
      case 'summarize':
        return Icons.summarize_outlined;
      case 'notes':
        return Icons.menu_book_outlined;
      case 'flashcards':
        return Icons.flash_on_outlined;
      case 'quiz':
        return Icons.quiz_outlined;
      case 'define':
        return Icons.book_outlined;
      case 'idiom':
        return Icons.format_quote_outlined;
      default:
        return Icons.auto_stories;
    }
  }

  Future<void> _saveContent() async {
    try {
      final db = ref.read(databaseServiceProvider);

      await db.saveNote(Note(
        title: widget.title,
        content: widget.content,
        sourceText: widget.sourceText,
      ));

      if (widget.actionType == 'flashcards') {
        // Parse and save flashcards
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  void _shareContent() {
    Clipboard.setData(ClipboardData(text: widget.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard, ready to share')),
    );
  }
}
