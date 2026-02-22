import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import '../../../../redux/app_state.dart';
import '../../redux/subjects_actions.dart';
import '../../../../core/localization/localization_manager.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final int subjectId;
  final String title;

  const SubjectDetailsScreen({super.key, required this.subjectId, required this.title});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, void>(
      onInit: (store) => store.dispatch(FetchSubjectContentAction(subjectId)),
      converter: (store) {},
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: GridView.count(
          padding: const EdgeInsets.all(24),
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _buildDetailTile(context, 'lectures'.tr(), Icons.play_lesson, Colors.orange, 'lectures'),
            _buildDetailTile(context, 'sections'.tr(), Icons.people, Colors.green, 'sections'),
            _buildDetailTile(context, 'quizzes'.tr(), Icons.quiz, Colors.purple, 'quizzes'),
            _buildDetailTile(context, 'tasks'.tr(), Icons.task, Colors.blue, 'tasks'),
            _buildDetailTile(context, 'summaries'.tr(), Icons.summarize, Colors.teal, 'summaries'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(BuildContext context, String label, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () => context.push('/subjects/$subjectId/$route'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
