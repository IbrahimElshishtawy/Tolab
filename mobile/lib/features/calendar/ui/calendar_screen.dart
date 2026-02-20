import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Column(
        children: [
          _buildCalendarHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildScheduleItem('08:30 AM', 'Introduction to CS', 'Lecture Hall A'),
                _buildScheduleItem('10:15 AM', 'Software Engineering', 'Room 201'),
                _buildScheduleItem('01:00 PM', 'Database Lab', 'Lab 3'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
          final isToday = index == 2; // Mock Wednesday as today
          return Column(
            children: [
              Text(days[index], style: TextStyle(color: isToday ? Colors.blue : Colors.grey)),
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: isToday ? Colors.blue : Colors.transparent,
                child: Text('${15 + index}', style: TextStyle(color: isToday ? Colors.white : Colors.black)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildScheduleItem(String time, String title, String location) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(time.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(time.split(' ')[1], style: const TextStyle(fontSize: 10)),
          ],
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }
}
