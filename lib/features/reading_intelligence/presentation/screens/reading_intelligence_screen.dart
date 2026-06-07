import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_service.dart';
import '../../../../shared/models/isar_models.dart';

final vocabularyProvider = FutureProvider<List<VocabularyWord>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getAllVocabularyWords();
});

final flashcardReviewProvider = FutureProvider<List<Flashcard>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getFlashcardsForReview();
});

class ReadingIntelligenceScreen extends ConsumerStatefulWidget {
  const ReadingIntelligenceScreen({super.key});

  @override
  ConsumerState<ReadingIntelligenceScreen> createState() => _ReadingIntelligenceScreenState();
}

class _ReadingIntelligenceScreenState extends ConsumerState<ReadingIntelligenceScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final vocabularyAsync = ref.watch(vocabularyProvider);
    final flashcardAsync = ref.watch(flashcardReviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Intelligence'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsCards(colorScheme),
          const SizedBox(height: 20),
          _buildSectionHeader('Vocabulary Builder', Icons.menu_book_outlined, colorScheme),
          const SizedBox(height: 8),
          _buildVocabularyPreview(vocabularyAsync, colorScheme),
          const SizedBox(height: 20),
          _buildSectionHeader('Flashcard Review', Icons.flash_on_outlined, colorScheme),
          const SizedBox(height: 8),
          _buildFlashcardPreview(flashcardAsync, colorScheme),
          const SizedBox(height: 20),
          _buildSectionHeader('Learning Progress', Icons.trending_up_outlined, colorScheme),
          const SizedBox(height: 8),
          _buildLearningProgress(colorScheme),
          const SizedBox(height: 20),
          _buildSectionHeader('Daily Insights', Icons.lightbulb_outlined, colorScheme),
          const SizedBox(height: 8),
          _buildDailyInsights(colorScheme),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Words', '24', Icons.text_fields, colorScheme)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Phrases', '12', Icons.format_quote, colorScheme)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Flashcards', '8', Icons.flash_on, colorScheme)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, ColorScheme colorScheme) {
    final color = icon == Icons.flash_on ? Colors.amber : colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildVocabularyPreview(
      AsyncValue<List<VocabularyWord>> vocabularyAsync, ColorScheme colorScheme) {
    return vocabularyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (words) {
        if (words.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.menu_book_outlined, size: 48,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text('No words collected yet',
                      style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  Text('Use "Explain Difficult Words" while reading',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Column(
            children: words.take(5).map((word) {
              return ListTile(
                dense: true,
                title: Text(word.word, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(word.definition ?? 'No definition',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Icon(
                  word.isKnown ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: word.isKnown ? Colors.green : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFlashcardPreview(
      AsyncValue<List<Flashcard>> flashcardAsync, ColorScheme colorScheme) {
    return flashcardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (cards) {
        if (cards.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.flash_on_outlined, size: 48,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text('No flashcards due for review',
                      style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Column(
            children: cards.take(3).map((card) {
              return ListTile(
                dense: true,
                title: Text(card.question, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('Reviews: ${card.reviewCount} · Difficulty: ${card.difficulty}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: card.difficulty < 2 ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    card.difficulty < 2 ? 'Easy' : 'Medium',
                    style: TextStyle(
                      fontSize: 11,
                      color: card.difficulty < 2 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildLearningProgress(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressBar('Vocabulary', 0.35, colorScheme),
            const SizedBox(height: 12),
            _buildProgressBar('Phrases', 0.20, colorScheme),
            const SizedBox(height: 12),
            _buildProgressBar('Flashcards', 0.50, colorScheme),
            const SizedBox(height: 12),
            _buildProgressBar('Summaries', 0.15, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
            Text('${(progress * 100).toInt()}%',
                style: TextStyle(fontSize: 13, color: colorScheme.primary)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyInsights(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lightbulb, color: colorScheme.onTertiaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading Streak',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You read for 30 minutes today. Keep it up!',
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
