import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/reading_actions/presentation/providers/reading_actions_provider.dart';

class ReadingActionChip extends ConsumerWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String actionType;
  final String text;

  const ReadingActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.actionType,
    required this.text,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      side: BorderSide(color: color.withOpacity(0.3)),
      onPressed: () {
        ref.read(readingActionsProvider.notifier).executeAction(actionType, text);
      },
    );
  }
}
