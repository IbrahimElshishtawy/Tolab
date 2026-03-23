import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';

class AdminOfferingsScreen extends StatelessWidget {
  const AdminOfferingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Course Offerings',
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.l),
        itemCount: 6,
        itemBuilder: (context, index) => AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Course Offering ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Fall 2023 - Section A'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Bulk Enroll',
        child: const Icon(Icons.assignment_ind),
      ),
    );
  }
}
