import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_background.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shareText = ref.watch(shareTextProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
      ),
      body: SafeArea(
        child: AppBackground(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _buildSectionHeader(context, 'Share'),
              Card(
                child: Column(
                  children: [
                    SettingsTile(
                      title: 'Share History',
                      subtitle: 'Export your adherence stats',
                      onTap: () => Share.share(shareText),
                      trailing: Icon(Icons.share, color: scheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _buildSectionHeader(context, 'About'),
              Card(
                child: const Column(
                  children: [
                    SettingsTile(
                      title: 'Version',
                      subtitle: AppConstants.appVersion,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'This app is a simple personal checklist and does not provide medical advice.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: textTheme.labelLarge?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // Notifications are controlled by the OS (Android/iOS system settings).
  // This screen intentionally doesn't provide user-facing test/debug actions.
}
