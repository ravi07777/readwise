import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/floating_assistant/presentation/screens/home_screen.dart';
import '../../features/ai_providers/presentation/screens/ai_providers_screen.dart';
import '../../features/prompt_library/presentation/screens/prompt_library_screen.dart';
import '../../features/prompt_library/presentation/screens/prompt_editor_screen.dart';
import '../../features/context_memory/presentation/screens/context_memory_screen.dart';
import '../../features/reading_intelligence/presentation/screens/reading_intelligence_screen.dart';
import '../../features/reading_chat/presentation/screens/reading_chat_screen.dart';
import '../../features/reading_chat/presentation/screens/chat_detail_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HomeScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const ReadingChatScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ReadingChatScreen(),
          ),
          GoRoute(
            path: '/chat/:id',
            builder: (context, state) => ChatDetailScreen(
              conversationId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: '/memory',
            builder: (context, state) => const ContextMemoryScreen(),
          ),
          GoRoute(
            path: '/intelligence',
            builder: (context, state) => const ReadingIntelligenceScreen(),
          ),
          GoRoute(
            path: '/prompts',
            builder: (context, state) => const PromptLibraryScreen(),
          ),
          GoRoute(
            path: '/prompts/new',
            builder: (context, state) => const PromptEditorScreen(),
          ),
          GoRoute(
            path: '/prompts/:id',
            builder: (context, state) => PromptEditorScreen(
              promptId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/providers',
            builder: (context, state) => const AIProvidersScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
