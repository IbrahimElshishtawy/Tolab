import 'package:flutter/widgets.dart';

enum CourseWorkspaceLanguage {
  english('en', TextDirection.ltr),
  arabic('ar', TextDirection.rtl);

  const CourseWorkspaceLanguage(this.code, this.direction);

  final String code;
  final TextDirection direction;

  static CourseWorkspaceLanguage fromCode(String? value) {
    final normalized = value?.toLowerCase() ?? 'en';
    return normalized.startsWith('ar')
        ? CourseWorkspaceLanguage.arabic
        : CourseWorkspaceLanguage.english;
  }
}

class CourseWorkspaceCopy {
  const CourseWorkspaceCopy(this.language);

  final CourseWorkspaceLanguage language;

  bool get isArabic => language == CourseWorkspaceLanguage.arabic;

  String text(String english, String arabic) {
    return isArabic ? arabic : english;
  }
}
