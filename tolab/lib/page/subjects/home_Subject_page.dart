import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/page/subjects/controller/home_subject_controller.dart';

import 'package:tolab/page/subjects/presentation/domain/models/Add_Subject_Page.dart';
import 'package:tolab/page/subjects/subject_page.dart';
import 'package:tolab/page/subjects/presentation/domain/models/subject_view_model.dart';

class HomeSubjectPage extends StatelessWidget {
  const HomeSubjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeSubjectController(
        Provider.of<SubjectViewModel>(context, listen: false),
      )..init(),
      child: Consumer2<HomeSubjectController, SubjectViewModel>(
        builder: (context, controller, viewModel, child) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('المواد'),
              centerTitle: true,
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
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
                              builder: (_) =>
                                  SubjectPage(subjectId: subject.id),
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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
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
            floatingActionButton: controller.isTeacher
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddSubjectPage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.add),
                  )
                : null,
          );
        },
      ),
    );
  }
}
