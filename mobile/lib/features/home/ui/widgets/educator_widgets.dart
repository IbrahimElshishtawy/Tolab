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
          const Text('Doctor Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('My Subjects', '3', Colors.blue, Icons.book),
              const SizedBox(width: 12),
              _buildStatCard('Pending Subs', '12', Colors.orange, Icons.assignment_late),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Upcoming', '2', Colors.red, Icons.notification_important),
              const SizedBox(width: 12),
              _buildStatCard('Avg Grade', 'B+', Colors.purple, Icons.grade),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickAction(context, 'Create Task', Icons.add_task, Colors.teal),
                _buildQuickAction(context, 'New Lecture', Icons.video_call, Colors.blue),
                _buildQuickAction(context, 'Announcement', Icons.campaign, Colors.orange),
              ],
            ),
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

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ActionChip(
        avatar: Icon(icon, color: Colors.white, size: 18),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening $label...')));
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
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
          const Text('Assistant Workspace', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat('Grading', '15', Colors.teal),
              const SizedBox(width: 12),
              _buildMiniStat('Labs', '2', Colors.indigo),
              const SizedBox(width: 12),
              _buildMiniStat('Queries', '5', Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          const Text('My Schedule Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildScheduleItem('09:00 AM', 'Lab 1 - CS101', 'Room 302'),
          _buildScheduleItem('11:30 AM', 'Office Hours', 'Staff Room'),
          const SizedBox(height: 24),
          const Text('To-Do List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildActionItem(Icons.grade, 'Grade 15 pending assignments', Colors.teal),
          _buildActionItem(Icons.science, 'Prepare Lab 4 materials', Colors.indigo),
          _buildActionItem(Icons.chat, 'Respond to 5 student queries', Colors.deepOrange),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
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
