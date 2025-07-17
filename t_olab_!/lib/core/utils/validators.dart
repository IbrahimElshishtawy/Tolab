// lib/core/utils/validators.dart

class Validators {
  /// ✅ حقل إجباري
  static String? required(String? value, {String fieldName = "هذا الحقل"}) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName مطلوب";
    }
    return null;
  }

  /// ✅ التحقق من البريد الإلكتروني العام
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "البريد الإلكتروني مطلوب";
    }

    final emailRegex = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value)) {
      return "صيغة البريد غير صحيحة";
    }
    return null;
  }

  /// ✅ التحقق من البريد الجامعي (مثال: user@stu.tanta.edu.eg)
  static String? universityEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "البريد الجامعي مطلوب";
    }

    final uniRegex = RegExp(r"^[\w\.\-]+@stu\.tanta\.edu\.eg$");
    if (!uniRegex.hasMatch(value)) {
      return "يجب استخدام بريد جامعي من @stu.tanta.edu.eg";
    }
    return null;
  }

  /// ✅ كلمة المرور
  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return "كلمة المرور يجب أن تكون 6 أحرف أو أكثر";
    }
    return null;
  }

  /// ✅ تأكيد كلمة المرور
  static String? confirmPassword(String? value, String original) {
    if (value != original) {
      return "كلمتا المرور غير متطابقتين";
    }
    return null;
  }

  /// ✅ رقم الهاتف
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final phoneRegex = RegExp(r'^\+?\d{7,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return "رقم الهاتف غير صالح";
    }
    return null;
  }

  /// ✅ التحقق من الاسم (يحتوي على حروف فقط)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "الاسم مطلوب";
    }

    final nameRegex = RegExp(r"^[\u0600-\u06FFa-zA-Z\s]{2,}$");
    if (!nameRegex.hasMatch(value)) {
      return "الاسم يجب أن يحتوي على حروف فقط";
    }
    return null;
  }

  /// ✅ العمر (عدد بين 10 و 100 مثلاً)
  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "العمر مطلوب";
    }

    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 10 || parsed > 100) {
      return "العمر يجب أن يكون رقمًا بين 10 و 100";
    }
    return null;
  }

  /// ✅ الرقم القومي (14 رقم)
  static String? nationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "الرقم القومي مطلوب";
    }

    final idRegex = RegExp(r'^\d{14}$');
    if (!idRegex.hasMatch(value)) {
      return "الرقم القومي يجب أن يحتوي على 14 رقمًا";
    }
    return null;
  }
}
