import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlatformChannelService {
  PlatformChannelService._();
  static final PlatformChannelService instance = PlatformChannelService._();

  static const MethodChannel _ocrChannel = MethodChannel('com.readwise.ai/ocr');
  static const MethodChannel _screenChannel = MethodChannel('com.readwise.ai/screen');
  static const MethodChannel _clipboardChannel = MethodChannel('com.readwise.ai/clipboard_native');
  static const MethodChannel _platformChannel = MethodChannel('com.readwise.ai/platform');
  static const MethodChannel _shareChannel = MethodChannel('com.readwise.ai/share');

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  // OCR Methods
  Future<Uint8List?> performOcr(String imagePath) async {
    try {
      final result = await _ocrChannel.invokeMethod<List<dynamic>>(
        'performOcr',
        {'imagePath': imagePath},
      );
      if (result != null) {
        return Uint8List.fromList(result.cast<int>());
      }
    } on MissingPluginException {
      debugPrint('OCR plugin not available');
    }
    return null;
  }

  // Screen Methods
  Future<Map<String, dynamic>?> getScreenDimensions() async {
    try {
      final result = await _screenChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getScreenDimensions',
      );
      if (result != null) {
        return result.cast<String, dynamic>();
      }
    } on MissingPluginException {
      // ignore
    }
    return null;
  }

  // Clipboard Methods
  Future<String?> getClipboardText() async {
    try {
      final result = await _clipboardChannel.invokeMethod<String>('getClipboardText');
      return result;
    } on MissingPluginException {
      return null;
    }
  }

  Future<bool> setClipboardText(String text) async {
    try {
      await _clipboardChannel.invokeMethod('setClipboardText', {'text': text});
      return true;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> hasClipboardText() async {
    try {
      final result = await _clipboardChannel.invokeMethod<bool>('hasClipboardText');
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> startClipboardMonitoring() async {
    try {
      await _clipboardChannel.invokeMethod('startMonitoring');
    } on MissingPluginException {
      // ignore
    }
  }

  // Platform Methods
  Future<String?> getPlatformVersion() async {
    try {
      final result = await _platformChannel.invokeMethod<String>('getPlatformVersion');
      return result;
    } on MissingPluginException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDeviceInfo() async {
    try {
      final result = await _platformChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getDeviceInfo',
      );
      if (result != null) {
        return result.cast<String, dynamic>();
      }
    } on MissingPluginException {
      // ignore
    }
    return null;
  }

  Future<bool> hasOverlayPermission() async {
    try {
      final result = await _platformChannel.invokeMethod<bool>('hasOverlayPermission');
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  // Share Methods
  Future<String?> getSharedText() async {
    try {
      final result = await _shareChannel.invokeMethod<String>('getSharedText');
      return result;
    } on MissingPluginException {
      return null;
    }
  }

  void dispose() {
    // Clean up if needed
  }
}

final platformChannelServiceProvider = Provider<PlatformChannelService>((ref) {
  return PlatformChannelService.instance;
});
