import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tolab/models/subject_model.dart';

class GetSubjects {
  final FirebaseFirestore firestore;

  GetSubjects({required this.firestore});

  /// 🔹 جلب كل المواد
  Future<List<SubjectModel>> call() async {
    try {
      final snapshot = await firestore.collection('subjects').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SubjectModel.fromJson({
          'id': doc.id,
          'name': data['name'] ?? '',
          'teacher': data['teacher'] ?? '',
          'description': data['description'] ?? '',
          'progress': (data['progress'] ?? 0.0).toDouble(),
        }, doc.id);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching subjects: $e');
      }
      return [];
    }
  }
}
