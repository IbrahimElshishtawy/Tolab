import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';

class AdminModerationScreen extends StatelessWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Moderation',
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.l),
        itemCount: 3,
        itemBuilder: (context, index) => AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                  const SizedBox(width: AppSpacing.s),
                  const Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Text('Reported', style: TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              const Text('This is a reported post content that needs to be reviewed by the admin for moderation.'),
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Keep',
                      isTonal: true,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
