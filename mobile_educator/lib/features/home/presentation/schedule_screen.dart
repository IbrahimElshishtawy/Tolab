import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Schedule')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CS Department - Year 3', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                _buildRow(['Time', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'], isHeader: true),
                _buildRow(['08:00', 'SE', '', 'DB', '', 'OS']),
                _buildRow(['10:00', '', 'AI', '', 'NW', '']),
                _buildRow(['12:00', 'PROJ', '', 'PROJ', '', '']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      children: cells.map((cell) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(cell, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
      )).toList(),
    );
  }
}
