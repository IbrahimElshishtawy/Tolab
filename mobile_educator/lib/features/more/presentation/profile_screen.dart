import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildInfoItem('Name', 'Ahmed Mohamed Ali'),
          _buildInfoItem('Code', 'EDU-2023-001'),
          _buildInfoItem('Religion', 'Muslim'),
          _buildInfoItem('Nationality', 'Egyptian'),
          _buildInfoItem('Date of Birth', '1985-05-12'),
          _buildInfoItem('Place of Birth', 'Cairo'),
          _buildInfoItem('Marital Status', 'Married'),
          _buildInfoItem('ID Number', '28505120102345'),
          _buildInfoItem('ID Type', 'National ID'),
          const Divider(height: 40),
          const Text('Qualification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildInfoItem('Qualification', 'Ph.D. in Computer Science'),
          _buildInfoItem('School', 'Cairo University'),
          _buildInfoItem('Year', '2015'),
          _buildInfoItem('Grade', 'Excellent'),
          _buildInfoItem('Percentage', '98%'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        ],
      ),
    );
  }
}
