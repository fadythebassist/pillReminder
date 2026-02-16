import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants.dart';
import '../../core/services/notification_service.dart';
import '../../providers/app_providers.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockoutHours = ref.watch(lockoutHoursProvider);
    final shareText = ref.watch(shareTextProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1976D2),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader('Lockout Duration'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Prevents taking the same medicine again within this time period after a dose is marked as taken.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...AppConstants.lockoutOptions.map((hours) => _buildLockoutOption(
              context,
              ref,
              hours,
              lockoutHours,
            )),
            const SizedBox(height: 24),
            _buildSectionHeader('Notifications'),
            SettingsTile(
              title: 'Enable Notifications',
              subtitle: 'Allow reminders to alert you',
              onTap: () => _requestNotificationPermissions(context, ref),
              trailing: const Icon(
                Icons.security,
                color: Color(0xFF1976D2),
              ),
            ),
            SettingsTile(
              title: 'Test Notification',
              subtitle: 'Send a test notification now',
              onTap: () => _sendTestNotification(context),
              trailing: const Icon(
                Icons.notifications_active,
                color: Color(0xFF1976D2),
              ),
            ),
            SettingsTile(
              title: 'Scheduled Test (1 min)',
              subtitle: 'Schedules a notification in 1 minute',
              onTap: () => _scheduleQuickTest(context),
              trailing: const Icon(
                Icons.alarm,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Share'),
            SettingsTile(
              title: 'Share History',
              subtitle: 'Export your adherence stats',
              onTap: () => Share.share(shareText),
              trailing: const Icon(
                Icons.share,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('About'),
            const SettingsTile(
              title: 'Version',
              subtitle: AppConstants.appVersion,
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'This app is a simple personal checklist and does not provide medical advice.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }

  Widget _buildLockoutOption(
    BuildContext context,
    WidgetRef ref,
    int hours,
    int currentHours,
  ) {
    return SettingsTile(
      title: '$hours hour${hours > 1 ? 's' : ''}',
      trailing: Icon(
        currentHours == hours
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked,
        color: currentHours == hours
            ? const Color(0xFF1976D2)
            : Colors.grey,
      ),
      onTap: () {
        ref.read(lockoutHoursProvider.notifier).setHours(hours);
      },
    );
  }

  void _sendTestNotification(BuildContext context) async {
    await NotificationService.sendTestNotification();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent!')),
      );
    }
  }

  void _scheduleQuickTest(BuildContext context) async {
    await NotificationService.scheduleQuickTest();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scheduled test notification in 1 minute.')),
      );
    }
  }

  void _requestNotificationPermissions(BuildContext context, WidgetRef ref) async {
    final granted = await NotificationService.requestPermissions();
    if (granted) {
      final reminders = ref.read(remindersProvider);
      await NotificationService.scheduleAllReminders(reminders);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'Notifications enabled.'
                : 'Notifications are disabled. Enable them in system settings.',
          ),
        ),
      );
    }
  }
}
