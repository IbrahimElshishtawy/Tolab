// 📁 lib/core/utils/national_id_parser.dart

class NationalIdParser {
  /// استخراج تاريخ الميلاد من الرقم القومي المصري
  static DateTime? extractBirthDate(String nationalId) {
    if (nationalId.length != 14) return null;

    try {
      final centuryDigit = nationalId[0];
      final year = int.parse(nationalId.substring(1, 3));
      final month = int.parse(nationalId.substring(3, 5));
      final day = int.parse(nationalId.substring(5, 7));

      int fullYear;
      if (centuryDigit == '2') {
        fullYear = 1900 + year;
      } else if (centuryDigit == '3') {
        fullYear = 2000 + year;
      } else {
        return null;
      }

      return DateTime(fullYear, month, day);
    } catch (_) {
      return null;
    }
  }

  /// استخراج النوع من الرقم القومي (ذكر / أنثى)
  static String? extractGender(String nationalId) {
    if (nationalId.length != 14) return null;

    try {
      final genderDigit = int.parse(nationalId[12]);
      return genderDigit % 2 == 0 ? 'أنثى' : 'ذكر';
    } catch (_) {
      return null;
    }
  }

  /// استخراج المحافظة من الرقم القومي
  static String? extractCity(String nationalId) {
    if (nationalId.length != 14) return null;

    try {
      final code = int.parse(nationalId.substring(7, 9));

      const cityMap = {
        1: 'القاهرة',
        2: 'الإسكندرية',
        3: 'بورسعيد',
        4: 'السويس',
        11: 'دمياط',
        12: 'الدقهلية',
        13: 'الشرقية',
        14: 'القليوبية',
        15: 'كفر الشيخ',
        16: 'الغربية',
        17: 'المنوفية',
        18: 'البحيرة',
        19: 'الإسماعيلية',
        21: 'الجيزة',
        22: 'بني سويف',
        23: 'الفيوم',
        24: 'المنيا',
        25: 'أسيوط',
        26: 'سوهاج',
        27: 'قنا',
        28: 'أسوان',
        29: 'الأقصر',
        31: 'البحر الأحمر',
        32: 'الوادي الجديد',
        33: 'مطروح',
        34: 'شمال سيناء',
        35: 'جنوب سيناء',
      };

      return cityMap[code] ?? 'غير معروفة';
    } catch (_) {
      return null;
    }
  }
}
