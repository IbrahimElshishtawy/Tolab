import 'package:flutter/material.dart';
import '../../../../core/localization/localization_manager.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Personal Information'),
            _buildInfoLabel('Name', 'Ahmed Mohamed Ali'),
            _buildInfoLabel('Code', '2023001'),
            _buildInfoLabel('Religion', 'Muslim'),
            _buildInfoLabel('Nationality', 'Egyptian'),
            _buildInfoLabel('Date of Birth', '15/05/2002'),
            _buildInfoLabel('Place of Birth', 'Cairo'),
            _buildInfoLabel('Marital Status', 'Single'),
            _buildInfoLabel('ID Number', '30205150100234'),
            _buildInfoLabel('ID Type', 'National ID'),
            _buildInfoLabel('Date of Issue', '20/01/2020'),
            _buildInfoLabel('Place of Issue', 'Cairo'),
            _buildInfoLabel('Father\'s Name', 'Mohamed Ali'),
            _buildInfoLabel('Mother\'s Name', 'Sara Ahmed'),
            _buildInfoLabel('Enrollment Status', 'Regular'),
            _buildInfoLabel('Admission Type', 'General'),
            _buildInfoLabel('Year of Admission', '2023'),
            const SizedBox(height: 32),
            _buildSectionHeader('Previous Qualification'),
            _buildInfoLabel('Qualification', 'High School Diploma'),
            _buildInfoLabel('School', 'Cairo Secondary School'),
            _buildInfoLabel('Year of Qualification', '2023'),
            _buildInfoLabel('Grade', 'Excellent'),
            _buildInfoLabel('Percentage', '98.5%'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildInfoLabel(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
