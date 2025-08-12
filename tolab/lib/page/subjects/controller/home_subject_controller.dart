import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tolab/page/subjects/presentation/domain/models/subject_view_model.dart';

class HomeSubjectController extends ChangeNotifier {
  final SubjectViewModel subjectViewModel;
  bool isTeacher = false;
  bool loading = true;

  HomeSubjectController(this.subjectViewModel);

  Future<void> init() async {
    await _checkUserRole();
    subjectViewModel.fetchSubjects();
  }

  Future<void> _checkUserRole() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final role = doc.data()?['role'];

    isTeacher = role == 'doctor' || role == 'assistant';
    loading = false;
    notifyListeners();
  }
}
