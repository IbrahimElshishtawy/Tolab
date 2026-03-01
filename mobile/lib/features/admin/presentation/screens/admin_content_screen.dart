import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';

class AdminContentScreen extends StatelessWidget {
  const AdminContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Manage Content',
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.l),
        itemCount: 4,
        itemBuilder: (context, index) => AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Course Offering ${index + 1}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.s),
              const Text('8 Lectures • 4 Tasks • 2 Exams'),
              const SizedBox(height: AppSpacing.l),
              AppButton(
                text: 'Upload Content',
                isTonal: true,
                icon: Icons.upload_file,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
