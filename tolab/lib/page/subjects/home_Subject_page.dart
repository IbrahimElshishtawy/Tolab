import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tolab/page/subjects/presentation/domain/models/subject_view_model.dart';
import 'package:tolab/page/subjects/subject_page.dart';

class HomeSubjectPage extends StatefulWidget {
  const HomeSubjectPage({super.key});

  @override
  State<HomeSubjectPage> createState() => _HomeSubjectPageState();
}

class _HomeSubjectPageState extends State<HomeSubjectPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<SubjectViewModel>(context, listen: false).fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SubjectViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('المواد'), centerTitle: true),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // عدد الأعمدة
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: viewModel.subjects.length,
              itemBuilder: (context, index) {
                final subject = viewModel.subjects[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubjectPage(subjectId: subject.id),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              subject.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.book, size: 50),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subject.teacher,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
