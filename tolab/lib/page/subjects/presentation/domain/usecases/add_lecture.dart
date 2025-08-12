import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolab/page/subjects/presentation/domain/models/lecture.dart';

class AddLecture {
  final FirebaseFirestore firestore;

  AddLecture({required this.firestore});

  Future<void> call(String subjectId, Lecture lecture) async {
    try {
      await firestore
          .collection('subjects')
          .doc(subjectId)
          .collection('lectures')
          .add(lecture.toMap());
    } catch (e) {
      throw Exception('Failed to add lecture: $e');
    }
  }
}
