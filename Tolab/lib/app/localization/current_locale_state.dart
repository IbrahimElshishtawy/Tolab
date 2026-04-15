class CurrentLocaleState {
  CurrentLocaleState._();

  static String _languageCode = 'en';

  static String get languageCode => _languageCode;

  static bool get isArabic => _languageCode == 'ar';

  static void update(String languageCode) {
    _languageCode = languageCode == 'ar' ? 'ar' : 'en';
  }
}
