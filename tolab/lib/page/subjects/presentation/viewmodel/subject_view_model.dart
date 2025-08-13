// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolab/models/subject_model.dart';

class SubjectViewModel extends ChangeNotifier {
  List<SubjectModel> subjects = [];
  bool isLoading = false;
  String? errorMessage;

  /// 🔹 جلب كل المواد من Firestore
  Future<void> fetchSubjects() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .orderBy('name')
          .get();

      subjects = snapshot.docs
          .map((doc) => SubjectModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      errorMessage = "خطأ أثناء تحميل المواد: $e";
      if (kDebugMode) print(errorMessage);
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

      // حفظ المادة في Firestore
      await FirebaseFirestore.instance
          .collection('subjects')
          .doc(newSubject.id)
          .set(newSubject.toJson());

      // إضافة المادة للقائمة المحلية
      subjects.add(newSubject);

      notifyListeners();
    } catch (e) {
      errorMessage = "خطأ أثناء إضافة المادة: $e";
      if (kDebugMode) print(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
