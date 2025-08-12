import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tolab/page/subjects/presentation/domain/models/detail_section.dart';
import 'package:tolab/page/subjects/presentation/domain/models/exam.dart';
import 'package:tolab/page/subjects/presentation/domain/models/lecture.dart';
import 'package:tolab/page/subjects/presentation/domain/models/subject.dart';
import 'package:tolab/page/subjects/presentation/domain/models/link_model.dart';

class SubjectViewModel extends ChangeNotifier {
  final String subjectId;
  SubjectViewModel(this.subjectId);

  Subject? subject;
  List<Lecture> lectures = [];
  List<Exam> exams = [];
  List<LinkModel> links = [];
  List<DetailSection> details = [];

  bool isLoading = false;

  Future<void> fetchSubjects() async {
    try {
      isLoading = true;
      notifyListeners();

      final firestore = FirebaseFirestore.instance;

      // 1️⃣ جلب بيانات المادة نفسها
      final subjectDoc = await firestore
          .collection('subjects')
          .doc(subjectId)
          .get();

      if (subjectDoc.exists) {
        subject = Subject.fromMap(subjectDoc.data()!, subjectDoc.id);
      }

      // 2️⃣ جلب المحاضرات الخاصة بالمادة
      final lecturesSnapshot = await firestore
          .collection('subjects')
          .doc(subjectId)
          .collection('lectures')
          .orderBy('date', descending: true)
          .get();

      lectures = lecturesSnapshot.docs
          .map((doc) => Lecture.fromMap(doc.data(), doc.id))
          .toList();

      // 3️⃣ جلب الامتحانات
      final examsSnapshot = await firestore
          .collection('subjects')
          .doc(subjectId)
          .collection('exams')
          .orderBy('date', descending: true)
          .get();

      exams = examsSnapshot.docs
          .map((doc) => Exam.fromMap(doc.data(), doc.id))
          .toList();

      // 4️⃣ جلب الروابط
      final linksSnapshot = await firestore
          .collection('subjects')
          .doc(subjectId)
          .collection('links')
          .get();

      links = linksSnapshot.docs
          .map((doc) => LinkModel.fromMap(doc.data(), doc.id))
          .toList();

      // 5️⃣ جلب التفاصيل
      final detailsSnapshot = await firestore
          .collection('subjects')
          .doc(subjectId)
          .collection('details')
          .get();

      details = detailsSnapshot.docs
          .map((doc) => DetailSection.fromMap(doc.data(), doc.id))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error loading subject data: $e");
      }
      isLoading = false;
      notifyListeners();
    }
  }
}
