import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tolab/models/subject_model.dart';

class GetSubjectDetails {
  final FirebaseFirestore firestore;

  GetSubjectDetails({required this.firestore});

  /// 🔹 جلب تفاصيل مادة واحدة باستخدام المعرف
  Future<SubjectModel?> call(String subjectId) async {
    try {
      final doc = await firestore.collection('subjects').doc(subjectId).get();

      if (doc.exists && doc.data() != null) {
        // إضافة id إلى البيانات قبل التحويل إلى SubjectModel
        final data = {'id': doc.id, ...doc.data()!};
        return SubjectModel.fromJson(data, doc.id);
      }

      return null; // إذا لم توجد المادة
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching subject details: $e');
      }
      return null; // عند حدوث أي خطأ
    }
  }
}
