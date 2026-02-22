import 'package:flutter/material.dart';
import '../../../../core/localization/localization_manager.dart';

class AcademicResultsScreen extends StatelessWidget {
  const AcademicResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('results'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildYearHeader(),
            const SizedBox(height: 24),
            const Text('Results Table', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildResultsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildYearHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.school, color: Colors.green),
              const SizedBox(width: 12),
              const Text('CS Department', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.green),
              const SizedBox(width: 12),
              const Text('Academic Year 2023/2024', style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.green.shade700),
        columns: const [
          DataColumn(label: Text('Subject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Grade', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
        rows: const [
          DataRow(cells: [DataCell(Text('Software Engineering')), DataCell(Text('A'))]),
          DataRow(cells: [DataCell(Text('Database Systems')), DataCell(Text('A-'))]),
          DataRow(cells: [DataCell(Text('Operating Systems')), DataCell(Text('B+'))]),
          DataRow(cells: [DataCell(Text('Algorithms')), DataCell(Text('A'))]),
          DataRow(cells: [DataCell(Text('Computer Networks')), DataCell(Text('B'))]),
        ],
      ),
    );
  }
}
