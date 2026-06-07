import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/overlay_service.dart';
import 'core/services/platform_channel_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/database/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  try {
    await SecureStorageService.instance.initialize();
  } catch (e) {
    debugPrint('SecureStorage init error: $e');
  }
  try {
    await DatabaseService.instance.initialize();
  } catch (e) {
    debugPrint('Database init error: $e');
  }
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }
  try {
    await PlatformChannelService.instance.initialize();
  } catch (e) {
    debugPrint('PlatformChannel init error: $e');
  }

  runApp(
    const ProviderScope(
      child: ReadWiseApp(),
    ),
  );
}
