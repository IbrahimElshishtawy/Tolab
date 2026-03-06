import 'package:flutter/material.dart';
import '../../../../core/localization/localization_manager.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLang = 'en'; // Should get from settings/preferences

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('language'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildLangOption('English', 'en'),
            const Divider(),
            _buildLangOption('العربية', 'ar'),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await LocalizationManager.load(_selectedLang);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language changed successfully')));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangOption(String label, String code) {
    return RadioListTile<String>(
      title: Text(label),
      value: code,
      groupValue: _selectedLang,
      onChanged: (val) {
        if (val != null) setState(() => _selectedLang = val);
      },
    );
  }
}
