import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverlayService {
  OverlayService._();
  static final OverlayService instance = OverlayService._();

  static const MethodChannel _channel = MethodChannel('com.readwise.ai/overlay');
  static const EventChannel _eventChannel = EventChannel('com.readwise.ai/overlay_events');

  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Stream<Map<String, dynamic>>? _eventStream;

  Future<bool> startOverlay() async {
    try {
      final result = await _channel.invokeMethod<bool>('startOverlay');
      _isRunning = result ?? false;
      return _isRunning;
    } on MissingPluginException {
      debugPrint('Overlay plugin not available');
      return false;
    }
  }

  Future<bool> stopOverlay() async {
    try {
      await _channel.invokeMethod('stopOverlay');
      _isRunning = false;
      return true;
    } on MissingPluginException {
      return false;
    }
  }

  Future<Map<String, double>> getOverlayPosition() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getOverlayPosition');
      if (result != null) {
        return {
          'x': (result['x'] as num).toDouble(),
          'y': (result['y'] as num).toDouble(),
        };
      }
    } on MissingPluginException {
      // ignore
    }
    return {'x': 0, 'y': 300};
  }

  Future<void> updateOverlayPosition(double x, double y) async {
    try {
      await _channel.invokeMethod('updateOverlayPosition', {'x': x, 'y': y});
    } on MissingPluginException {
      // ignore
    }
  }

  Stream<Map<String, dynamic>> get overlayEvents {
    _eventStream ??= _eventChannel.receiveBroadcastStream().map(
      (event) => Map<String, dynamic>.from(event as Map),
    );
    return _eventStream!;
  }

  void dispose() {
    _eventStream = null;
  }
}

final overlayServiceProvider = Provider<OverlayService>((ref) {
  return OverlayService.instance;
});

final overlayStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(overlayServiceProvider);
  return service.overlayEvents.map((event) {
    return event['isRunning'] as bool? ?? false;
  });
});
