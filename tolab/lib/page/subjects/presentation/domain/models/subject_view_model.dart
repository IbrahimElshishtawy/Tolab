// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject.dart';
import '../models/lecture.dart';
import '../models/exam.dart';

import '../models/detail_section.dart';

class SubjectViewModel extends ChangeNotifier {
  List<Subject> _subjects = [];
  bool _isLoading = false;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;

  /// تحميل المواد من الكاش أو API
  Future<void> loadSubjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? cachedData = prefs.getString('subjects_cache');

      if (cachedData != null) {
        print("📦 تحميل المواد من الكاش");
        List decoded = jsonDecode(cachedData);
        _subjects = decoded.map((e) => Subject.fromJson(e)).toList();
      } else {
        print("🌐 تحميل المواد من API");
        _subjects = await _fetchSubjectsFromApi();
        await _saveSubjectsToCache(_subjects);
      }
    } catch (e) {
      print("❌ خطأ أثناء تحميل المواد: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تحديث المواد وحفظها في الكاش
  Future<void> refreshSubjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      _subjects = await _fetchSubjectsFromApi();
      await _saveSubjectsToCache(_subjects);
    } catch (e) {
      print("❌ خطأ أثناء تحديث المواد: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// حفظ المواد في الكاش
  Future<void> _saveSubjectsToCache(List<Subject> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(subjects.map((e) => e.toJson()).toList());
    await prefs.setString('subjects_cache', jsonString);
    print("✅ تم حفظ المواد في الكاش");
  }

  /// مثال لجلب المواد من API (ممكن تعدله حسب API بتاعك)
  Future<List<Subject>> _fetchSubjectsFromApi() async {
    await Future.delayed(const Duration(seconds: 1)); // محاكاة تحميل البيانات
    return [
      Subject(
        id: "s101",
        title: "برمجة متقدمة",
        teacherName: "د. أحمد",
        fileCount: 5,
        icon: "code",
        lectures: [
          Lecture(
            id: "l1",
            title: "مقدمة",
            fileUrl: "https://example.com/lec1.pdf",
          ),
        ],
        exams: [
          Exam(
            id: "e1",
            title: "امتحان نصفي",
            fileUrl: "https://example.com/exam1.pdf",
          ),
        ],
        links: [LinkModel(title: "الموقع الرسمي", url: "https://example.com")],
        details: [
          DetailSection(title: "ملاحظات", content: "ملاحظات عن المادة..."),
        ],
      ),
    ];
  }
}
