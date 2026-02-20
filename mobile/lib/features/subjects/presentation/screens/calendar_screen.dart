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
                _buildScheduleItem('09:00 AM', 'CS101 - Lecture', 'Hall 1'),
                _buildScheduleItem('11:00 AM', 'SWE311 - Section', 'Lab 4'),
                _buildScheduleItem('02:00 PM', 'Assignment Deadline', 'Online', isDeadline: true),
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _DayItem('Mon', '12'),
          _DayItem('Tue', '13', isSelected: true),
          _DayItem('Wed', '14'),
          _DayItem('Thu', '15'),
          _DayItem('Fri', '16'),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String time, String title, String location, {bool isDeadline = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
        title: Text(title),
        subtitle: Text(location),
        trailing: isDeadline ? const Icon(Icons.timer, color: Colors.red) : const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;
  const _DayItem(this.day, this.date, {this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: TextStyle(color: isSelected ? Colors.blue : Colors.grey)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(date, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
        ),
      ],
    );
  }
}
