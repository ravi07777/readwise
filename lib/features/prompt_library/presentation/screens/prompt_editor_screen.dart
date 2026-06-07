import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_service.dart';
import '../../../../shared/models/isar_models.dart';

class PromptEditorScreen extends ConsumerStatefulWidget {
  final String? promptId;

  const PromptEditorScreen({super.key, this.promptId});

  @override
  ConsumerState<PromptEditorScreen> createState() => _PromptEditorScreenState();
}

class _PromptEditorScreenState extends ConsumerState<PromptEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isFavorite = false;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.promptId != null) {
      _loadPrompt();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadPrompt() async {
    if (widget.promptId == null) return;
    final id = int.tryParse(widget.promptId!);
    if (id == null) return;

    final db = ref.read(databaseServiceProvider);
    final prompt = await db.getPrompt(id);
    if (prompt != null && mounted) {
      _titleController.text = prompt.title;
      _contentController.text = prompt.content;
      _categoryController.text = prompt.category ?? '';
      _tagsController.text = prompt.tags.join(', ');
      setState(() {
        _isFavorite = prompt.isFavorite;
        _isDefault = prompt.isDefault;
      });
    }
  }

  Future<void> _savePrompt() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseServiceProvider);
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final prompt = Prompt(
        title: title,
        content: content,
        category: _categoryController.text.trim().isNotEmpty
            ? _categoryController.text.trim()
            : null,
        tags: tags,
        isFavorite: _isFavorite,
        isDefault: _isDefault,
        isBuiltIn: false,
      );

      if (widget.promptId != null) {
        final id = int.tryParse(widget.promptId!);
        if (id != null) {
          final existing = await db.getPrompt(id);
          if (existing != null) {
            await db.savePrompt(existing
              ..title = title
              ..content = content
              ..category = _categoryController.text.trim().isNotEmpty
                  ? _categoryController.text.trim()
                  : null
              ..tags = tags
              ..isFavorite = _isFavorite
              ..isDefault = _isDefault
              ..updatedAt = DateTime.now());
          }
        }
      } else {
        await db.savePrompt(prompt);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.promptId != null ? 'Prompt updated' : 'Prompt created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.promptId != null ? 'Edit Prompt' : 'New Prompt'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePrompt,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Enter prompt title',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Prompt Content',
              hintText: 'Use {text} where the reading content should be inserted',
              alignLabelWithHint: true,
            ),
            maxLines: 10,
            minLines: 6,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 8),
          Text(
            'Use {text} as a placeholder for where the reading content will be inserted',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'e.g., Reading, Translation',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    hintText: 'tag1, tag2, tag3',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mark as Favorite'),
                  value: _isFavorite,
                  onChanged: (value) => setState(() => _isFavorite = value),
                  secondary: Icon(
                    Icons.favorite,
                    color: _isFavorite ? Colors.red : colorScheme.onSurfaceVariant,
                  ),
                ),
                SwitchListTile(
                  title: const Text('Use as Default Prompt'),
                  subtitle: const Text('This prompt will be used for quick actions'),
                  value: _isDefault,
                  onChanged: (value) => setState(() => _isDefault = value),
                  secondary: Icon(
                    Icons.star,
                    color: _isDefault ? Colors.amber : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (widget.promptId != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outlined, color: Colors.red),
              label: const Text('Delete Prompt', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Prompt'),
                    content: const Text('Are you sure? This cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && widget.promptId != null) {
                  final id = int.tryParse(widget.promptId!);
                  if (id != null) {
                    await ref.read(databaseServiceProvider).deletePrompt(id);
                    if (mounted) Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
