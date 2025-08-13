// lib/features/subjects/viewmodel/subject_view_model.dart
import 'package:flutter/material.dart';
import 'package:tolab/models/subject_model.dart';
import '../data/subject_repository.dart';

class SubjectViewModel extends ChangeNotifier {
  final SubjectRepository _repository = SubjectRepository();

  List<SubjectModel> _subjects = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SubjectModel> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// تحميل المواد من Firebase Firestore
  Future<void> fetchSubjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _subjects = await _repository.getSubjects();
    } catch (e) {
      _errorMessage = "حدث خطأ أثناء تحميل المواد: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  /// إضافة مادة جديدة
  Future<void> addSubject(SubjectModel subject) async {
    try {
      await _repository.addSubject(subject);
      _subjects.add(subject);
      notifyListeners();
    } catch (e) {
      _errorMessage = "تعذر إضافة المادة: $e";
      notifyListeners();
    }
  }

  /// تحديث مادة
  Future<void> updateSubject(SubjectModel updatedSubject) async {
    try {
      await _repository.updateSubject(updatedSubject);
      int index = _subjects.indexWhere((s) => s.id == updatedSubject.id);
      if (index != -1) {
        _subjects[index] = updatedSubject;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "تعذر تحديث المادة: $e";
      notifyListeners();
    }
  }

  /// حذف مادة
  Future<void> deleteSubject(String id) async {
    try {
      await _repository.deleteSubject(id);
      _subjects.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = "تعذر حذف المادة: $e";
      notifyListeners();
    }
  }

  void fetchAllSubjects() {}
}
