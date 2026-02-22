import 'package:flutter/material.dart';
import '../../../../core/localization/localization_manager.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('schedule_nav'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildYearInfo(),
            const SizedBox(height: 24),
            Text('Weekly Timetable', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildScheduleGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildYearInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.school, color: Colors.blue),
              const SizedBox(width: 12),
              const Text('CS Department', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.blue),
              const SizedBox(width: 12),
              const Text('Academic Year 2023/2024', style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleGrid() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
    final times = ['08:00', '10:00', '12:00', '02:00'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: MaterialStateProperty.all(Colors.blue.shade700),
        border: TableBorder.all(color: Colors.grey.shade300),
        columns: [
          const DataColumn(label: Text('Time', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ...days.map((day) => DataColumn(label: Text(day, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        ],
        rows: times.map((time) {
          return DataRow(
            cells: [
              DataCell(Text(time, style: const TextStyle(fontWeight: FontWeight.bold))),
              ...days.map((day) {
                // Mock data
                String subject = '';
                if (day == 'Mon' && time == '08:00') subject = 'SE (Lec)';
                if (day == 'Wed' && time == '10:00') subject = 'DB (Sec)';
                if (day == 'Thu' && time == '12:00') subject = 'OS (Lec)';

                return DataCell(
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: Text(subject, style: TextStyle(fontSize: 12, color: subject.isNotEmpty ? Colors.blue.shade800 : Colors.black)),
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }
}
