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
        ],
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
          const Text('Assistant Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildActionItem(Icons.grade, 'Grade 15 pending assignments', Colors.teal),
          _buildActionItem(Icons.lab_profile, 'Prepare Lab 4 materials', Colors.indigo),
          _buildActionItem(Icons.chat, 'Respond to 5 student queries', Colors.deepOrange),
        ],
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
