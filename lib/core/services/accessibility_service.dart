import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessibilityService {
  AccessibilityService._();
  static final AccessibilityService instance = AccessibilityService._();

  static const MethodChannel _channel = MethodChannel('com.readwise.ai/accessibility');

  Future<bool> isAccessibilityEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAccessibilityEnabled');
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } on MissingPluginException {
      // ignore
    }
  }

  Future<String?> getSelectedText() async {
    try {
      final result = await _channel.invokeMethod<String>('getSelectedText');
      return result;
    } on MissingPluginException {
      return null;
    }
  }
}

final accessibilityServiceProvider = Provider<AccessibilityService>((ref) {
  return AccessibilityService.instance;
});
