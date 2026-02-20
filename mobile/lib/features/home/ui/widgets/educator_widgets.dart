import 'package:flutter/material.dart';

class DoctorHomeDashboard extends StatelessWidget {
  const DoctorHomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Doctor Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard('Total Students', '450', Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('Active Courses', '3', Colors.green),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('Submissions', '85%', Colors.orange),
              const SizedBox(width: 16),
              _buildStatCard('Avg Grade', 'B+', Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildActivityItem('New submission in SWE311 from Ali', '10 mins ago', Icons.history_edu),
          _buildActivityItem('Quiz results published for CS101', '2 hours ago', Icons.analytics),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: Text(time, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class AssistantHomeDashboard extends StatelessWidget {
  const AssistantHomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Schedule Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildScheduleItem('09:00 AM', 'Lab 1 - CS101', 'Room 302'),
          _buildScheduleItem('11:30 AM', 'Office Hours', 'Staff Room'),
          const SizedBox(height: 24),
          const Text('Pending Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildActionItem(Icons.grade, 'Grade 15 pending assignments', Colors.teal),
          _buildActionItem(Icons.science, 'Prepare Lab 4 materials', Colors.indigo),
          _buildActionItem(Icons.chat, 'Respond to 5 student queries', Colors.deepOrange),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String time, String title, String room) {
    return Card(
      child: ListTile(
        leading: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        title: Text(title),
        subtitle: Text(room),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String text, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}
