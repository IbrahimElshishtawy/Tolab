import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  const AppLocalizations(this.locale, this._translations);

  static const List<String> _modules = <String>[
    'common',
    'auth',
    'layout',
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  final Locale locale;
  final Map<String, dynamic> _translations;

  static AppLocalizations of(BuildContext context) {
    final localization = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localization != null, 'AppLocalizations is not available.');
    return localization!;
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final translations = <String, dynamic>{};

    for (final module in _modules) {
      final raw = await rootBundle.loadString(
        'assets/lang/${locale.languageCode}/$module.json',
      );
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _deepMerge(translations, decoded);
    }

    return AppLocalizations(locale, translations);
  }

  String t(
    String key, {
    String? fallback,
    Map<String, String> params = const <String, String>{},
  }) {
    final resolved = _resolveKey(key);
    final text = resolved is String ? resolved : (fallback ?? key);
    return _applyParams(text, params);
  }

  String byValue(String value) {
    if (value.isEmpty) {
      return value;
    }

    final exact = _translations['by_value'];
    var translated = value;
    if (exact is Map) {
      final mapped = exact[value];
      if (mapped is String && mapped.isNotEmpty) {
        translated = mapped;
      }
    }

    final fragments = _translations['by_fragment'];
    if (fragments is Map) {
      for (final entry in fragments.entries) {
        final source = entry.key;
        final replacement = entry.value;
        if (source is String &&
            replacement is String &&
            source.isNotEmpty &&
            translated.contains(source)) {
          translated = translated.replaceAll(source, replacement);
        }
      }
    }

    return translated;
  }

  dynamic _resolveKey(String key) {
    dynamic current = _translations;
    for (final part in key.split('.')) {
      if (current is! Map || !current.containsKey(part)) {
        return null;
      }
      current = current[part];
    }
    return current;
  }

  String _applyParams(String template, Map<String, String> params) {
    var result = template;
    for (final entry in params.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  static void _deepMerge(
    Map<String, dynamic> target,
    Map<String, dynamic> source,
  ) {
    for (final entry in source.entries) {
      final existing = target[entry.key];
      final next = entry.value;
      if (existing is Map<String, dynamic> && next is Map<String, dynamic>) {
        _deepMerge(existing, next);
        continue;
      }

      if (existing is Map && next is Map) {
        final normalized = Map<String, dynamic>.from(existing);
        _deepMerge(normalized, Map<String, dynamic>.from(next));
        target[entry.key] = normalized;
        continue;
      }

      target[entry.key] = next;
    }
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'ar';

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
