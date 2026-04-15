import 'package:flutter/widgets.dart';

extension AppLocalizationContext on BuildContext {
  bool get isEnglish => Localizations.localeOf(this).languageCode == 'en';

  bool get isArabic => !isEnglish;

  TextDirection get appTextDirection =>
      isEnglish ? TextDirection.ltr : TextDirection.rtl;

  String tr(String ar, String en) => isEnglish ? en : ar;
}
