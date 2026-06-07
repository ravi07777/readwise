import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/overlay_service.dart';
import '../../../../core/services/accessibility_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overlay Section
          _buildSectionHeader('Overlay & Floating Assistant', Icons.adjust_outlined, colorScheme),
          _buildSettingsCard([
            SwitchListTile(
              title: const Text('Floating Assistant'),
              subtitle: const Text('Show floating AI button above other apps'),
              value: settings.overlayEnabled,
              onChanged: (value) async {
                if (value) {
                  final started = await OverlayService.instance.startOverlay();
                  await ref.read(appSettingsProvider.notifier).updateOverlayEnabled(started);
                } else {
                  await OverlayService.instance.stopOverlay();
                  await ref.read(appSettingsProvider.notifier).updateOverlayEnabled(false);
                }
              },
            ),
          ]),

          const SizedBox(height: 16),

          // Accessibility Section
          _buildSectionHeader('Accessibility', Icons.accessibility_outlined, colorScheme),
          _buildSettingsCard([
            ListTile(
              title: const Text('Accessibility Service'),
              subtitle: const Text('Detect selected text in other apps'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final service = AccessibilityService.instance;
                final enabled = await service.isAccessibilityEnabled();
                if (!enabled) {
                  await service.openAccessibilitySettings();
                }
              },
            ),
            SwitchListTile(
              title: const Text('Auto-detect Selected Text'),
              subtitle: const Text('Automatically capture selected text'),
              value: settings.accessibilityEnabled,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).updateSetting('accessibility_enabled', value);
              },
            ),
          ]),

          const SizedBox(height: 16),

          // Clipboard Section
          _buildSectionHeader('Clipboard', Icons.content_paste_outlined, colorScheme),
          _buildSettingsCard([
            SwitchListTile(
              title: const Text('Clipboard Monitoring'),
              subtitle: const Text('Detect copied text and suggest actions'),
              value: settings.clipboardMonitoring,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).updateClipboardMonitoring(value);
              },
            ),
          ]),

          const SizedBox(height: 16),

          // Screen Capture Section
          _buildSectionHeader('Screen Capture & OCR', Icons.camera_alt_outlined, colorScheme),
          _buildSettingsCard([
            SwitchListTile(
              title: const Text('Auto OCR'),
              subtitle: const Text('Automatically OCR when no text is selected'),
              value: settings.autoOCREnabled,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).updateSetting('auto_ocr_enabled', value);
              },
            ),
          ]),

          const SizedBox(height: 16),

          // Appearance Section
          _buildSectionHeader('Appearance', Icons.palette_outlined, colorScheme),
          _buildSettingsCard([
            ListTile(
              title: const Text('Theme'),
              subtitle: Text(
                themeMode == ThemeMode.light
                    ? 'Light'
                    : themeMode == ThemeMode.dark
                        ? 'Dark'
                        : 'System',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeSelector(context, ref, themeMode),
            ),
            SwitchListTile(
              title: const Text('Dynamic Colors'),
              subtitle: const Text('Use Material 3 dynamic color scheme'),
              value: settings.dynamicColors,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).updateSetting('dynamic_colors', value);
              },
            ),
            SwitchListTile(
              title: const Text('Animations'),
              subtitle: const Text('Enable UI animations'),
              value: settings.animationsEnabled,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).updateSetting('animations_enabled', value);
              },
            ),
          ]),

          const SizedBox(height: 16),

          // AI Section
          _buildSectionHeader('AI Settings', Icons.smart_toy_outlined, colorScheme),
          _buildSettingsCard([
            ListTile(
              title: const Text('AI Providers'),
              subtitle: const Text('Manage API keys and models'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/providers'),
            ),
            ListTile(
              title: const Text('Prompt Library'),
              subtitle: const Text('Manage AI prompts and templates'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/prompts'),
            ),
          ]),

          const SizedBox(height: 16),

          // Data & Privacy Section
          _buildSectionHeader('Data & Privacy', Icons.security_outlined, colorScheme),
          _buildSettingsCard([
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('No Ads'),
              subtitle: Text('This app is ad-free'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('No Tracking'),
              subtitle: Text('No analytics or tracking'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('No Account Required'),
              subtitle: Text('Everything works offline and locally'),
            ),
            ListTile(
              title: const Text('Clear All Local Data'),
              subtitle: const Text('Delete all saved data'),
              trailing: const Icon(Icons.delete_outline, color: Colors.red),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear All Data'),
                    content: const Text('This will delete all prompts, notes, flashcards, conversations, and vocabulary. This cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(secureStorageServiceProvider).clear();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All data cleared')),
                    );
                  }
                }
              },
            ),
          ]),

          const SizedBox(height: 16),

          // About Section
          _buildSectionHeader('About', Icons.info_outline, colorScheme),
          _buildSettingsCard([
            const ListTile(
              title: Text('Version'),
              subtitle: Text('1.0.0'),
            ),
            const ListTile(
              title: Text('Developer'),
              subtitle: Text('ReadWise AI Team'),
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref, ThemeMode current) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Choose Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              trailing: current == ThemeMode.light ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              trailing: current == ThemeMode.dark ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_suggest),
              title: const Text('System'),
              trailing: current == ThemeMode.system ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
