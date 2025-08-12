import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolab/models/subject_model.dart';

class SubjectMapper {
  /// من Firestore → SubjectModel
  static SubjectModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      progress: (data['progress'] ?? 0).toDouble(),
    );
  }

  /// من SubjectModel → Firestore
  static Map<String, dynamic> toFirestore(SubjectModel subject) {
    return {
      'name': subject.name,
      'description': subject.description,
      'progress': subject.progress,
    };
  }
}
