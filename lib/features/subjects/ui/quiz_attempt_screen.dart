// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../data/models.dart';

class QuizAttemptScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizAttemptScreen({super.key, required this.quiz});

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  int _currentQuestionIndex = 0;
  final List<int?> _answers = List.generate(5, (_) => null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '45:00',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: (_currentQuestionIndex + 1) / 5),
            const SizedBox(height: 24),
            Text(
              'Question ${_currentQuestionIndex + 1} of 5',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              _getMockQuestion(_currentQuestionIndex),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...List.generate(4, (i) => _buildOption(i)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  TextButton(
                    onPressed: () => setState(() => _currentQuestionIndex--),
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox(),
                ElevatedButton(
                  onPressed: () {
                    if (_currentQuestionIndex < 4) {
                      setState(() => _currentQuestionIndex++);
                    } else {
                      _finishQuiz();
                    }
                  },
                  child: Text(_currentQuestionIndex < 4 ? 'Next' : 'Finish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index) {
    final isSelected = _answers[_currentQuestionIndex] == index;
    return Card(
      color: isSelected ? Colors.blue.withOpacity(0.1) : null,
      child: RadioListTile<int>(
        title: Text('Option ${String.fromCharCode(65 + index)}'),
        value: index,
        groupValue: _answers[_currentQuestionIndex],
        onChanged: (val) =>
            setState(() => _answers[_currentQuestionIndex] = val),
      ),
    );
  }

  String _getMockQuestion(int index) {
    final questions = [
      'What is the primary purpose of Redux?',
      'Which widget is used for handling state in Flutter?',
      'What does "InheritedWidget" do?',
      'Explain the use of "Middleware" in Redux.',
      'How do you trigger a state change in Redux?',
    ];
    return questions[index];
  }

  void _finishQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: const Text('Your answers have been submitted successfully.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close attempt
              Navigator.pop(context); // close details
            },
            child: const Text('Back to Course'),
          ),
        ],
      ),
    );
  }
}
