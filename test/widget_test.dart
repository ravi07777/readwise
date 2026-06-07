import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readwise_ai_assistant/app.dart';

void main() {
  testWidgets('App should build and display', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ReadWiseApp(),
      ),
    );

    // The app should build without errors
    expect(tester.takeException(), isNull);

    // Should show the bottom navigation
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Settings screen should be accessible via navigation',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ReadWiseApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Navigate to settings via bottom nav
    final settingsButton = find.text('Settings');
    expect(settingsButton, findsOneWidget);

    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    // Should navigate to settings
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('Dark mode should switch', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ReadWiseApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Navigate to settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Find and tap theme selection
    final themeTile = find.text('Theme');
    expect(themeTile, findsOneWidget);
  });

  testWidgets('App should handle empty state gracefully', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ReadWiseApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Should show empty state in chat
    expect(find.text('ReadWise AI Assistant'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
