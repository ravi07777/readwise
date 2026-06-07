import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_service.dart';
import '../../../../shared/models/isar_models.dart';

final readingSessionsProvider = FutureProvider<List<ReadingSession>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getRecentSessions(limit: 50);
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getRecentConversations(limit: 50);
});

class ContextMemoryScreen extends ConsumerWidget {
  const ContextMemoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final sessionsAsync = ref.watch(readingSessionsProvider);
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Memory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search memory',
            onPressed: () {
              // Implement search
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(text: 'Reading Sessions'),
                Tab(text: 'Conversations'),
                Tab(text: 'Saved'),
              ],
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSessionsTab(sessionsAsync, colorScheme),
                  _buildConversationsTab(conversationsAsync, colorScheme),
                  _buildSavedTab(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsTab(
      AsyncValue<List<ReadingSession>> sessionsAsync, ColorScheme colorScheme) {
    return sessionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (sessions) {
        if (sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text('No reading sessions yet',
                    style: TextStyle(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Text('Start reading and use AI actions to track progress',
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.auto_stories,
                      color: colorScheme.onPrimaryContainer, size: 20),
                ),
                title: Text(
                  session.title ?? 'Untitled Session',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${session.source} · ${session.totalCharacters} chars · '
                  '${_formatDate(session.startedAt)}',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                trailing: Text(
                  session.isActive ? 'Active' : 'Ended',
                  style: TextStyle(
                    fontSize: 12,
                    color: session.isActive ? Colors.green : colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  // Show session details
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildConversationsTab(
      AsyncValue<List<Conversation>> conversationsAsync, ColorScheme colorScheme) {
    return conversationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (conversations) {
        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text('No conversations yet',
                    style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conv = conversations[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.chat,
                      color: colorScheme.onSecondaryContainer, size: 20),
                ),
                title: Text(
                  conv.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${conv.messageCount} messages · ${_formatDate(conv.updatedAt)}',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                onTap: () {
                  // Navigate to conversation
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSavedTab(ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSavedCard(Icons.note_outlined, 'Notes', 'View saved notes', colorScheme),
        _buildSavedCard(Icons.flash_on_outlined, 'Flashcards', 'Review flashcards', colorScheme),
        _buildSavedCard(Icons.summarize_outlined, 'Summaries', 'View saved summaries', colorScheme),
        _buildSavedCard(Icons.bookmark_outlined, 'Bookmarks', 'View bookmarks', colorScheme),
        _buildSavedCard(Icons.highlight_outlined, 'Highlights', 'View highlights', colorScheme),
        _buildSavedCard(Icons.menu_book_outlined, 'Vocabulary', 'Saved words and phrases', colorScheme),
      ],
    );
  }

  Widget _buildSavedCard(
      IconData icon, String title, String subtitle, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        onTap: () {},
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
