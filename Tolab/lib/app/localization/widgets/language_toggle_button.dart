import 'package:flutter/material.dart';

import '../app_localizations.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({
    super.key,
    required this.languageCode,
    required this.onSelected,
  });

  final String languageCode;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentLabel = l10n.t(
      'common.languages.$languageCode',
      fallback: languageCode.toUpperCase(),
    );

    return PopupMenuButton<String>(
      tooltip: l10n.t('common.language'),
      onSelected: onSelected,
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          child: Text(l10n.t('common.languages.en')),
        ),
        PopupMenuItem<String>(
          value: 'ar',
          child: Text(l10n.t('common.languages.ar')),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate_rounded, size: 18),
            const SizedBox(width: 8),
            Text(
              currentLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
