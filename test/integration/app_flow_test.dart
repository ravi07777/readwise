import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readwise_ai_assistant/app.dart';

void main() {
  group('App Flow', () {
    testWidgets('Full navigation flow', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ReadWiseApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial state shows chat
      expect(find.text('ReadWise AI Assistant'), findsOneWidget);

      // Navigate to Memory
      await tester.tap(find.text('Memory'));
      await tester.pumpAndSettle();
      expect(find.text('Reading Memory'), findsOneWidget);

      // Navigate to Intelligence
      await tester.tap(find.text('Intelligence'));
      await tester.pumpAndSettle();
      expect(find.text('Reading Intelligence'), findsOneWidget);

      // Navigate to Prompts
      await tester.tap(find.text('Prompts'));
      await tester.pumpAndSettle();
      expect(find.text('Prompt Library'), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);

      // Navigate back to Chat
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      expect(find.text('ReadWise AI Assistant'), findsOneWidget);
    });

    testWidgets('Chat input should work', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ReadWiseApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find text field and type
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Explain this text');
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text('Explain this text'), findsOneWidget);
    });

    testWidgets('Quick action chips should be visible', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ReadWiseApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Quick actions should be visible in empty state
      expect(find.text('Explain'), findsOneWidget);
      expect(find.text('Summarize'), findsOneWidget);
      expect(find.text('Translate'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });
  });
}
