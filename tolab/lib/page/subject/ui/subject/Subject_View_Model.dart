// lib/features/subject/viewmodel/subject_view_model.dart
import 'package:flutter/material.dart';

class SubjectViewModel extends ChangeNotifier {
  final String subjectId;
  int currentTab = 0;

  SubjectViewModel({required this.subjectId});

  void onFabPressed(int tabIndex) {
    currentTab = tabIndex;
    switch (tabIndex) {
      case 0:
        // ارفع محاضرة
        break;
      case 1:
        // ارفع محتوى شرح مفصل
        break;
      case 2:
        // ارفع امتحان
        break;
      case 3:
        // ارفع رابط مفيد
        break;
    }
    notifyListeners();
  }
}
