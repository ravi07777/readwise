import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/overlay_service.dart';
import '../../../quick_menu/presentation/widgets/quick_action_menu.dart';

class FloatingAssistantButton extends ConsumerStatefulWidget {
  const FloatingAssistantButton({super.key});

  @override
  ConsumerState<FloatingAssistantButton> createState() => _FloatingAssistantButtonState();
}

class _FloatingAssistantButtonState extends ConsumerState<FloatingAssistantButton>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  Offset _position = const Offset(0, 300);
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);
    _loadPosition();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadPosition() async {
    final pos = await OverlayService.instance.getOverlayPosition();
    if (mounted) {
      setState(() {
        _position = Offset(pos['x'] ?? 0, pos['y'] ?? 300);
      });
    }
  }

  void _showQuickMenu() {
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (ctx) => const QuickActionMenu(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pulseValue = _pulseController.value;

    return GestureDetector(
      onPanStart: (_) => setState(() => _isDragging = false),
      onPanUpdate: (details) {
        setState(() {
          _isDragging = true;
          _position += details.delta;
          _position = Offset(
            _position.dx.clamp(0, MediaQuery.of(context).size.width - 56),
            _position.dy.clamp(0, MediaQuery.of(context).size.height - 56),
          );
        });
      },
      onPanEnd: (details) {
        if (!_isDragging) {
          HapticFeedback.lightImpact();
          _showQuickMenu();
          return;
        }
        _snapToEdge();
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        _showQuickMenu();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withOpacity(0.12 * (0.5 + 0.5 * pulseValue)),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  void _snapToEdge() {
    final screenWidth = MediaQuery.of(context).size.width;
    final midPoint = _position.dx + 28;
    final snappedX = midPoint > screenWidth / 2 ? screenWidth - 56 : 0.0;

    setState(() {
      _position = Offset(snappedX, _position.dy);
    });

    OverlayService.instance.updateOverlayPosition(snappedX, _position.dy);
  }
}
