import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tolab/models/subject_model.dart';
import 'package:tolab/page/subjects/presentation/domain/models/detail_section.dart';
import 'package:tolab/page/subjects/presentation/domain/models/exam.dart';
import 'package:tolab/page/subjects/presentation/domain/models/lecture.dart';
import 'package:tolab/page/subjects/presentation/domain/models/subject.dart';
import 'package:tolab/page/subjects/presentation/domain/models/link_model.dart';

class SubjectViewModel extends ChangeNotifier {
  String? _subjectId;
  String? errorMessage;

  List<Subject> subjects = [];
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

  /// 🔹 جلب كل المواد
  Future<void> fetchAllSubjects() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .orderBy('name')
          .get();

      subjects = snapshot.docs
          .map((doc) => Subject.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      errorMessage = "خطأ أثناء تحميل المواد: $e";
      if (kDebugMode) print("❌ $errorMessage");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 جلب تفاصيل مادة واحدة
  Future<void> fetchSubjectDetails() async {
    if (_subjectId == null) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final firestore = FirebaseFirestore.instance;

      // المادة
      final subjectDoc = await firestore
          .collection('subjects')
          .doc(_subjectId)
          .get();
      if (subjectDoc.exists) {
        subject = Subject.fromMap(subjectDoc.data()!, subjectDoc.id);
      }

      // المحاضرات
      lectures = await _fetchCollection<Lecture>(
        firestore.collection('subjects').doc(_subjectId).collection('lectures'),
        (data, id) => Lecture.fromMap(data, id),
        orderBy: 'date',
      );

      // الامتحانات
      exams = await _fetchCollection<Exam>(
        firestore.collection('subjects').doc(_subjectId).collection('exams'),
        (data, id) => Exam.fromMap(data, id),
        orderBy: 'date',
      );

      // الروابط
      links = await _fetchCollection<LinkModel>(
        firestore.collection('subjects').doc(_subjectId).collection('links'),
        (data, id) => LinkModel.fromMap(data, id),
      );

      // التفاصيل
      details = await _fetchCollection<DetailSection>(
        firestore.collection('subjects').doc(_subjectId).collection('details'),
        (data, id) => DetailSection.fromMap(data, id),
      );
    } catch (e) {
      errorMessage = "خطأ أثناء تحميل تفاصيل المادة: $e";
      if (kDebugMode) print("❌ $errorMessage");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 إضافة مادة جديدة
  Future<void> addSubject(SubjectModel newSubject) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await FirebaseFirestore.instance
          .collection('subjects')
          .doc(newSubject.id)
          .set(newSubject.toJson());

      subjects.add(
        Subject(
          id: newSubject.id,
          name: newSubject.name,
          description: newSubject.description,
          progress: newSubject.progress,
          teacher: newSubject.teacher ?? '',
          imageUrl: newSubject.imageUrl ?? '',
        ),
      );
    } catch (e) {
      errorMessage = "خطأ أثناء إضافة المادة: $e";
      if (kDebugMode) print("❌ $errorMessage");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 دالة مساعده لجلب أي Collection
  Future<List<T>> _fetchCollection<T>(
    CollectionReference collection,
    T Function(Map<String, dynamic>, String) fromMap, {
    String? orderBy,
  }) async {
    Query query = collection;
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: true);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
