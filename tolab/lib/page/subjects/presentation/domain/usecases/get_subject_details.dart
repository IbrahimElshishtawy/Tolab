import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tolab/models/subject_model.dart';

class GetSubjectDetails {
  final FirebaseFirestore firestore;

  GetSubjectDetails({required this.firestore});

  Future<SubjectModel?> call(String subjectId) async {
    try {
      final doc = await firestore.collection('subjects').doc(subjectId).get();
      if (doc.exists) {
        return SubjectModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching subject details: $e');
      }
      return null;
    }
  }
}
