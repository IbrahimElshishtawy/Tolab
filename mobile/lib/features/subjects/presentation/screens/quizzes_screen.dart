import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../redux/app_state.dart';
import '../../data/models.dart';
import '../../../../core/localization/localization_manager.dart';

class QuizzesScreen extends StatelessWidget {
  final int subjectId;
  const QuizzesScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('quizzes'.tr()),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Online Quizzes'),
              Tab(text: 'Offline Quizzes'),
            ],
          ),
        ),
        body: StoreConnector<AppState, List<Quiz>>(
          converter: (store) => store.state.subjectsState.quizzes[subjectId] ?? [],
          builder: (context, quizzes) {
            final onlineQuizzes = quizzes.where((q) => q.type == QuizType.online).toList();
            final offlineQuizzes = quizzes.where((q) => q.type == QuizType.offline).toList();

            return TabBarView(
              children: [
                _buildQuizList(context, onlineQuizzes, true),
                _buildQuizList(context, offlineQuizzes, false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuizList(BuildContext context, List<Quiz> quizzes, bool isOnline) {
    if (quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No ${isOnline ? "online" : "offline"} quizzes available', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        final bool isStarted = DateTime.now().isAfter(quiz.startAt);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Week ${quiz.weekNumber}', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                    Text(quiz.ownerName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(quiz.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${quiz.sourceName}', style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${quiz.startAt.day}/${quiz.startAt.month}/${quiz.startAt.year}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${quiz.startAt.hour.toString().padLeft(2, '0')}:${quiz.startAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                if (isOnline) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isStarted
                          ? () {
                              _showQuizLink(context, quiz.quizUrl ?? 'https://quiz.example.com');
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Enter'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQuizLink(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Link'),
        content: Text('Click the link below to open the quiz:\n\n$url'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () {}, child: const Text('Open Link')),
        ],
      ),
    );
  }
}
