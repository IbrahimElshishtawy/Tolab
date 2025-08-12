import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolab/models/subject_model.dart';
import 'package:tolab/page/subjects/presentation/data/mappers.dart';

class SubjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'subjects';

  /// إحضار كل المواد
  Future<List<SubjectModel>> getSubjects() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => SubjectMapper.fromFirestore(doc))
        .toList();
  }

  /// إحضار مادة معينة حسب ID
  Future<SubjectModel?> getSubjectDetails(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return SubjectMapper.fromFirestore(doc);
    }
    return null;
  }

  /// إضافة مادة جديدة
  Future<void> addSubject(SubjectModel subject) async {
    await _firestore
        .collection(_collection)
        .doc(subject.id)
        .set(SubjectMapper.toFirestore(subject));
  }

  /// تعديل مادة
  Future<void> updateSubject(SubjectModel subject) async {
    await _firestore
        .collection(_collection)
        .doc(subject.id)
        .update(SubjectMapper.toFirestore(subject));
  }

  /// حذف مادة
  Future<void> deleteSubject(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
