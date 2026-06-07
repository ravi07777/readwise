import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_service.dart';
import '../../../../shared/models/isar_models.dart';

final promptsProvider = FutureProvider<List<Prompt>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getAllPrompts();
});

final favoritePromptsProvider = FutureProvider<List<Prompt>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getFavoritePrompts();
});

final builtInPrompts = [
  Prompt(
    title: 'Simplify English',
    content: 'Rewrite the following text in simple, easy-to-understand English. Use short sentences and common words. Explain any difficult concepts:\n\n{text}',
    category: 'Reading',
    tags: ['simplify', 'english'],
    isBuiltIn: true,
    sortOrder: 1,
  ),
  Prompt(
    title: 'Translate to Hindi',
    content: 'Translate the following text to Hindi. Preserve the meaning and tone:\n\n{text}',
    category: 'Translation',
    tags: ['translate', 'hindi'],
    isBuiltIn: true,
    sortOrder: 2,
  ),
  Prompt(
    title: 'Translate to Urdu',
    content: 'Translate the following text to Urdu. Preserve the meaning and tone:\n\n{text}',
    category: 'Translation',
    tags: ['translate', 'urdu'],
    isBuiltIn: true,
    sortOrder: 3,
  ),
  Prompt(
    title: 'Translate to Hinglish',
    content: 'Translate the following text to Hinglish (Hindi + English mix). Use casual, conversational style:\n\n{text}',
    category: 'Translation',
    tags: ['translate', 'hinglish'],
    isBuiltIn: true,
    sortOrder: 4,
  ),
  Prompt(
    title: 'Explain Like Beginner',
    content: 'Explain the following text as if I am a complete beginner. Use very simple words, analogies, and examples. Assume I have no prior knowledge of this topic:\n\n{text}',
    category: 'Explain',
    tags: ['explain', 'beginner'],
    isBuiltIn: true,
    sortOrder: 5,
  ),
  Prompt(
    title: 'Explain Like Teacher',
    content: 'Explain the following text as if you are a knowledgeable teacher. Break down complex ideas step by step. Use clear examples and connect concepts:\n\n{text}',
    category: 'Explain',
    tags: ['explain', 'teacher'],
    isBuiltIn: true,
    sortOrder: 6,
  ),
  Prompt(
    title: 'Explain Like Professor',
    content: 'Provide a scholarly analysis of the following text. Discuss its context, implications, methodology, and significance. Use academic language:\n\n{text}',
    category: 'Explain',
    tags: ['explain', 'academic'],
    isBuiltIn: true,
    sortOrder: 7,
  ),
  Prompt(
    title: 'Explain Idioms',
    content: 'Identify and explain any idioms, phrases, or figurative language in the following text. For each, provide: 1) The idiom/phrase 2) Its literal meaning 3) Its actual meaning 4) An example of usage:\n\n{text}',
    category: 'Language',
    tags: ['idioms', 'phrases'],
    isBuiltIn: true,
    sortOrder: 8,
  ),
  Prompt(
    title: 'Explain Phrases',
    content: 'Explain any notable phrases or expressions in the following text. Include their meaning, context, and usage:\n\n{text}',
    category: 'Language',
    tags: ['phrases'],
    isBuiltIn: true,
    sortOrder: 9,
  ),
  Prompt(
    title: 'Summarize Page',
    content: 'Provide a concise summary of the following text. Include the main points, key arguments, and important details. Keep it brief but comprehensive:\n\n{text}',
    category: 'Summary',
    tags: ['summarize'],
    isBuiltIn: true,
    sortOrder: 10,
  ),
  Prompt(
    title: 'Summarize Chapter',
    content: 'Summarize this chapter/ section. Include: 1) Main themes 2) Key arguments 3) Important evidence 4) Chapter conclusions 5) How it connects to previous chapters:\n\n{text}',
    category: 'Summary',
    tags: ['summarize', 'chapter'],
    isBuiltIn: true,
    sortOrder: 11,
  ),
  Prompt(
    title: 'Generate Notes',
    content: 'Create detailed study notes from the following text. Organize them with: headings, bullet points, key terms, definitions, and important concepts:\n\n{text}',
    category: 'Learning',
    tags: ['notes', 'study'],
    isBuiltIn: true,
    sortOrder: 12,
  ),
  Prompt(
    title: 'Generate Flashcards',
    content: 'Create a set of flashcards from the following text. For each flashcard, provide a question on one side and the answer on the other. Format as Q&A pairs:\n\n{text}',
    category: 'Learning',
    tags: ['flashcards', 'study'],
    isBuiltIn: true,
    sortOrder: 13,
  ),
  Prompt(
    title: 'Quiz Me',
    content: 'Create a quiz based on the following text. Include multiple choice questions, true/false questions, and short answer questions. Provide answers at the end:\n\n{text}',
    category: 'Learning',
    tags: ['quiz', 'test'],
    isBuiltIn: true,
    sortOrder: 14,
  ),
  Prompt(
    title: 'Reading Coach',
    content: 'Act as a reading coach. Help me understand the following text better by: 1) Checking my comprehension 2) Asking guiding questions 3) Providing reading strategies 4) Suggesting what to focus on next:\n\n{text}',
    category: 'Reading',
    tags: ['coach', 'comprehension'],
    isBuiltIn: true,
    sortOrder: 15,
  ),
  Prompt(
    title: 'Research Assistant',
    content: 'Analyze this text as a research assistant would. Provide: 1) Research methodology 2) Key findings 3) Limitations 4) Future research directions 5) Related papers/topics:\n\n{text}',
    category: 'Academic',
    tags: ['research', 'academic'],
    isBuiltIn: true,
    sortOrder: 16,
  ),
  Prompt(
    title: 'Academic Simplifier',
    content: 'Simplify this academic/research text for easier understanding. Maintain accuracy but use accessible language. Explain technical terms and methodology:\n\n{text}',
    category: 'Academic',
    tags: ['academic', 'simplify'],
    isBuiltIn: true,
    sortOrder: 17,
  ),
  Prompt(
    title: 'Legal Simplifier',
    content: 'Simplify this legal text for a non-lawyer. Explain legal terms, implications, and key points in plain language. Note any important warnings or obligations:\n\n{text}',
    category: 'Professional',
    tags: ['legal', 'simplify'],
    isBuiltIn: true,
    sortOrder: 18,
  ),
  Prompt(
    title: 'Medical Simplifier',
    content: 'Simplify this medical/health text for a patient. Explain medical terms, procedures, conditions, and treatments in plain language. Highlight important safety information:\n\n{text}',
    category: 'Professional',
    tags: ['medical', 'health'],
    isBuiltIn: true,
    sortOrder: 19,
  ),
  Prompt(
    title: 'Book Discussion',
    content: 'Engage in a thoughtful discussion about this text. Ask me questions about what I think, what surprised me, what I agree/disagree with, and what I want to explore further:\n\n{text}',
    category: 'Reading',
    tags: ['discussion', 'book'],
    isBuiltIn: true,
    sortOrder: 20,
  ),
  Prompt(
    title: 'Vocabulary Builder',
    content: 'Identify and explain difficult or uncommon words in the following text. For each word provide: 1) Definition 2) Pronunciation guide 3) Example sentence 4) Synonyms 5) Memory trick:\n\n{text}',
    category: 'Language',
    tags: ['vocabulary', 'words'],
    isBuiltIn: true,
    sortOrder: 21,
  ),
  Prompt(
    title: 'Memory Refresh',
    content: 'I read this before but need a refresher. Summarize the key points I should remember and remind me of the context:\n\n{text}',
    category: 'Reading',
    tags: ['memory', 'refresh'],
    isBuiltIn: true,
    sortOrder: 22,
  ),
  Prompt(
    title: 'What Did I Read?',
    content: 'Based on the following text, help me remember what I was reading. Provide context, summarize the main topic, and remind me of key points:\n\n{text}',
    category: 'Reading',
    tags: ['memory', 'context'],
    isBuiltIn: true,
    sortOrder: 23,
  ),
  Prompt(
    title: 'Explain Previous Context',
    content: 'I need to understand how the following text connects to what I read before. Explain the context, continuity, and any references to earlier material:\n\n{text}',
    category: 'Reading',
    tags: ['context', 'continuity'],
    isBuiltIn: true,
    sortOrder: 24,
  ),
];

class PromptLibraryScreen extends ConsumerStatefulWidget {
  const PromptLibraryScreen({super.key});

  @override
  ConsumerState<PromptLibraryScreen> createState() => _PromptLibraryScreenState();
}

class _PromptLibraryScreenState extends ConsumerState<PromptLibraryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final promptsAsync = ref.watch(promptsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt Library'),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_outline,
              color: _showFavoritesOnly ? Colors.red : null,
            ),
            tooltip: 'Favorites',
            onPressed: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Import Prompts',
            onPressed: _importPrompts,
          ),
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: 'Export Prompts',
            onPressed: _exportPrompts,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search prompts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: promptsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (prompts) {
                final allPrompts = [...builtInPrompts, ...prompts];
                var filtered = allPrompts.where((p) {
                  if (_showFavoritesOnly && !p.isFavorite) return false;
                  if (_selectedCategory != 'All' && p.category != _selectedCategory) return false;
                  if (_searchQuery.isNotEmpty) {
                    return p.title.toLowerCase().contains(_searchQuery) ||
                        p.content.toLowerCase().contains(_searchQuery) ||
                        p.tags.any((t) => t.contains(_searchQuery));
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.compare_outlined, size: 64,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('No prompts found',
                            style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '${filtered.length} prompts',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }
                    final prompt = filtered[index - 1];
                    return _PromptCard(
                      prompt: prompt,
                      onTap: () => context.go('/prompts/${prompt.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/prompts/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Prompt'),
      ),
    );
  }

  List<String> get _categories {
    final cats = <String>{'All'};
    for (final p in builtInPrompts) {
      if (p.category != null) cats.add(p.category!);
    }
    return cats.toList()..sort();
  }

  Future<void> _importPrompts() async {
    // Implementation for importing prompts from JSON
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paste JSON prompt data to import')),
    );
  }

  Future<void> _exportPrompts() async {
    final db = ref.read(databaseServiceProvider);
    final prompts = await db.getAllPrompts();
    final json = jsonEncode(prompts.map((p) => {
      'title': p.title,
      'content': p.content,
      'category': p.category,
      'tags': p.tags,
      'isFavorite': p.isFavorite,
    }).toList());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported ${prompts.length} prompts')),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final Prompt prompt;
  final VoidCallback onTap;

  const _PromptCard({required this.prompt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: prompt.isBuiltIn
                      ? colorScheme.secondaryContainer
                      : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  prompt.isBuiltIn ? Icons.auto_awesome : Icons.compare,
                  size: 20,
                  color: prompt.isBuiltIn
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            prompt.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (prompt.isFavorite)
                          const Icon(Icons.favorite, size: 16, color: Colors.red),
                        if (prompt.isDefault)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (prompt.category != null)
                      Text(
                        prompt.category!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }
}
