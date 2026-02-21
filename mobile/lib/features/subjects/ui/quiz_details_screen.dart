import 'package:flutter/material.dart';
import '../data/models.dart';
import 'quiz_attempt_screen.dart';

class QuizDetailsScreen extends StatelessWidget {
  final Quiz quiz;
  const QuizDetailsScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quiz.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.timer, 'Duration', '${quiz.durationMins} minutes'),
            _buildInfoRow(Icons.grade, 'Total Points', '${quiz.totalPoints} points'),
            _buildInfoRow(Icons.calendar_today, 'Start Time', quiz.startAt.toLocal().toString()),
            _buildInfoRow(Icons.calendar_today, 'End Time', quiz.endAt.toLocal().toString()),
            const Divider(height: 32),
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Ensure you have a stable internet connection.\n'
                '• Once started, the timer cannot be paused.\n'
                '• Answers are automatically submitted when time runs out.'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QuizAttemptScreen(quiz: quiz)),
                );
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}
