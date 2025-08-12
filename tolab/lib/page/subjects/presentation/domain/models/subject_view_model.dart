import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tolab/page/subjects/presentation/domain/models/detail_section.dart';
import 'package:tolab/page/subjects/presentation/domain/models/exam.dart';
import 'package:tolab/page/subjects/presentation/domain/models/lecture.dart';
import 'package:tolab/page/subjects/presentation/domain/models/subject.dart';
import 'package:tolab/page/subjects/presentation/domain/models/link_model.dart';

class SubjectViewModel extends ChangeNotifier {
  String? _subjectId;

  // 📌 قائمة كل المواد
  List<Subject> subjects = [];

  // 📌 تفاصيل مادة واحدة
  Subject? subject;
  List<Lecture> lectures = [];
  List<Exam> exams = [];
  List<LinkModel> links = [];
  List<DetailSection> details = [];

  bool isLoading = false;

  SubjectViewModel([String? subjectId]) {
    if (subjectId != null) {
      setSubjectId(subjectId);
    }
  }

  void setSubjectId(String subjectId) {
    _subjectId = subjectId;
    fetchSubjectDetails();
  }

  /// 1️⃣ جلب كل المواد
  Future<void> fetchAllSubjects() async {
    try {
      isLoading = true;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .get();

      subjects = snapshot.docs
          .map((doc) => Subject.fromMap(doc.data(), doc.id))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print("❌ Error loading subjects list: $e");
      }
    }
  }

  /// 2️⃣ جلب تفاصيل مادة واحدة
  Future<void> fetchSubjectDetails() async {
    if (_subjectId == null) return;

    try {
      isLoading = true;
      notifyListeners();

      final firestore = FirebaseFirestore.instance;

      // جلب بيانات المادة
      final subjectDoc = await firestore
          .collection('subjects')
          .doc(_subjectId)
          .get();

      if (subjectDoc.exists) {
        subject = Subject.fromMap(subjectDoc.data()!, subjectDoc.id);
      }

      // جلب المحاضرات
      final lecturesSnapshot = await firestore
          .collection('subjects')
          .doc(_subjectId)
          .collection('lectures')
          .orderBy('date', descending: true)
          .get();

      lectures = lecturesSnapshot.docs
          .map((doc) => Lecture.fromMap(doc.data(), doc.id))
          .toList();

      // جلب الامتحانات
      final examsSnapshot = await firestore
          .collection('subjects')
          .doc(_subjectId)
          .collection('exams')
          .orderBy('date', descending: true)
          .get();

      exams = examsSnapshot.docs
          .map((doc) => Exam.fromMap(doc.data(), doc.id))
          .toList();

      // جلب الروابط
      final linksSnapshot = await firestore
          .collection('subjects')
          .doc(_subjectId)
          .collection('links')
          .get();

      links = linksSnapshot.docs
          .map((doc) => LinkModel.fromMap(doc.data(), doc.id))
          .toList();

      // جلب التفاصيل
      final detailsSnapshot = await firestore
          .collection('subjects')
          .doc(_subjectId)
          .collection('details')
          .get();

      details = detailsSnapshot.docs
          .map((doc) => DetailSection.fromMap(doc.data(), doc.id))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print("❌ Error loading subject details: $e");
      }
    }
  }

  void fetchSubjects() {}
}
