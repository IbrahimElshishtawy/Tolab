// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/models/subject_model.dart';
import 'package:tolab/page/subjects/presentation/viewmodel/subject_view_model.dart';
import 'package:tolab/page/subjects/subject_page.dart';

class HomeSubjectPage extends StatelessWidget {
  const HomeSubjectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubjectViewModel()..fetchSubjects(),
      child: Consumer<SubjectViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('المواد'),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddSubjectDialog(context, vm),
                ),
              ],
            ),
            body: vm.subjects.isEmpty
                ? const Center(child: Text('لا توجد مواد حالياً'))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: vm.subjects.length,
                    itemBuilder: (context, index) {
                      final subject = vm.subjects[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubjectPage(
                                subjectId: subject.id,
                              ), // تمرير الـ id
                            ),
                          );
                        },

                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withOpacity(0.6),
                                Colors.transparent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                subject.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                (subject.teacher != null &&
                                        subject.teacher!.isNotEmpty)
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
                                  value: subject.progress.clamp(0.0, 1.0),
                                  minHeight: 8,
                                  backgroundColor: Colors.white24,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${((subject.progress) * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context, SubjectViewModel vm) {
    final nameController = TextEditingController();
    final teacherController = TextEditingController();
    final descriptionController = TextEditingController();
    double progress = 0.0;

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
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'وصف المادة'),
            ),
            Slider(
              value: progress,
              onChanged: (value) => progress = value,
              min: 0,
              max: 1,
            ),
            Text("نسبة التقدم: ${(progress * 100).toStringAsFixed(0)}%"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  teacherController.text.isNotEmpty) {
                final newSubject = SubjectModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  progress: progress,
                  teacher: teacherController.text.trim().isNotEmpty
                      ? teacherController.text.trim()
                      : 'غير معروف',
                );
                await vm.addSubject(newSubject);
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
