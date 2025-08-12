import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolab/models/subject_model.dart';

class GetSubjects {
  final FirebaseFirestore firestore;

  GetSubjects({required this.firestore});

  Future<List<SubjectModel>> call() async {
    try {
      final snapshot = await firestore.collection('subjects').get();
      return snapshot.docs.map((doc) {
        return SubjectModel.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }
}
