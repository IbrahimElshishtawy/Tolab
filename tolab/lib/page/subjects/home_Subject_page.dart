import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tolab/page/subjects/presentation/viewmodel/subject_view_model.dart';

class HomeSubjectPage extends StatelessWidget {
  final SubjectViewModel? subjectViewModel;

  const HomeSubjectPage({super.key, this.subjectViewModel});

  final List<List<Color>> gradientColors = const [
    [Colors.blue, Colors.lightBlueAccent],
    [Colors.green, Colors.lightGreenAccent],
    [Colors.orange, Colors.deepOrangeAccent],
    [Colors.purple, Colors.deepPurpleAccent],
    [Colors.teal, Colors.tealAccent],
    [Colors.red, Colors.redAccent],
    [Colors.indigo, Colors.indigoAccent],
    [Color(0xFF795548), Color(0xFFA1887F)],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المواد'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddSubjectDialog(context);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: subjectViewModel?.fetchAllSubjects(),
        builder: (context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (subjectViewModel == null || subjectViewModel!.subjects.isEmpty) {
            return const Center(child: Text('لا توجد مواد حالياً'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: subjectViewModel!.subjects.length,
            itemBuilder: (context, index) {
              final subject = subjectViewModel!.subjects[index];
              final colors = gradientColors[index % gradientColors.length];

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, size: 40, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      subject.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subject.teacher != null
                          ? 'د. ${subject.teacher}'
                          : 'دكتور غير معروف',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (subject.progress).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${((subject.progress) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Dialog لإضافة مادة جديدة
  void _showAddSubjectDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController teacherController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مادة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم المادة'),
            ),
            TextField(
              controller: teacherController,
              decoration: const InputDecoration(labelText: 'اسم الدكتور'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (subjectViewModel != null &&
                  nameController.text.isNotEmpty &&
                  teacherController.text.isNotEmpty) {
                subjectViewModel!.addSubject();
              }
              Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
