import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_web/core/network/api_client.dart';

class SystemSettings {
  final String defaultLanguage;
  final bool allowStudentsChangeLang;
  final bool allowStaffChangeLang;
  final bool enableNotifications;
  final int minPasswordLength;
  final bool requireComplexPassword;
  final int sessionTimeoutMins;

  SystemSettings({
    required this.defaultLanguage,
    required this.allowStudentsChangeLang,
    required this.allowStaffChangeLang,
    required this.enableNotifications,
    required this.minPasswordLength,
    required this.requireComplexPassword,
    required this.sessionTimeoutMins,
  });

  factory SystemSettings.fromJson(Map<String, dynamic> json) => SystemSettings(
        defaultLanguage: json['default_language'],
        allowStudentsChangeLang: json['allow_students_change_lang'],
        allowStaffChangeLang: json['allow_staff_change_lang'],
        enableNotifications: json['enable_notifications'],
        minPasswordLength: json['min_password_length'],
        requireComplexPassword: json['require_complex_password'],
        sessionTimeoutMins: json['session_timeout_mins'],
      );
}

final settingsProvider = FutureProvider((ref) async {
  final response = await ref.read(apiClientProvider).get('/admin/settings');
  return SystemSettings.fromJson(response.data);
});

class SystemSettingsScreen extends ConsumerStatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  ConsumerState<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends ConsumerState<SystemSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('System Settings')),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSection('General Settings', [
              ListTile(
                title: const Text('Default Language'),
                trailing: DropdownButton<String>(
                  value: settings.defaultLanguage,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ar', child: Text('Arabic')),
                  ],
                  onChanged: (val) => _updateSettings({'default_language': val}),
                ),
              ),
              SwitchListTile(
                title: const Text('Allow students to change language'),
                value: settings.allowStudentsChangeLang,
                onChanged: (val) => _updateSettings({'allow_students_change_lang': val}),
              ),
              SwitchListTile(
                title: const Text('Allow staff to change language'),
                value: settings.allowStaffChangeLang,
                onChanged: (val) => _updateSettings({'allow_staff_change_lang': val}),
              ),
            ]),
            const Divider(),
            _buildSection('Notification Settings', [
              SwitchListTile(
                title: const Text('Enable real-time notifications'),
                value: settings.enableNotifications,
                onChanged: (val) => _updateSettings({'enable_notifications': val}),
              ),
            ]),
            const Divider(),
            _buildSection('Security Settings', [
              ListTile(
                title: const Text('Minimum Password Length'),
                trailing: SizedBox(
                  width: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '8'),
                    onSubmitted: (val) => _updateSettings({'min_password_length': int.parse(val)}),
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Require complex passwords'),
                value: settings.requireComplexPassword,
                onChanged: (val) => _updateSettings({'require_complex_password': val}),
              ),
              ListTile(
                title: const Text('Session Timeout (minutes)'),
                trailing: SizedBox(
                  width: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '60'),
                    onSubmitted: (val) => _updateSettings({'session_timeout_mins': int.parse(val)}),
                  ),
                ),
              ),
            ]),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...children,
      ],
    );
  }

  Future<void> _updateSettings(Map<String, dynamic> data) async {
    try {
      await ref.read(apiClientProvider).patch('/admin/settings', data: data);
      ref.invalidate(settingsProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings updated')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
