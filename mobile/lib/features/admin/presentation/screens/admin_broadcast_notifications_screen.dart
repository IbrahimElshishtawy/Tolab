import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';

class AdminBroadcastNotificationsScreen extends StatelessWidget {
  const AdminBroadcastNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Broadcast',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Send Push Notification', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: AppSpacing.s),
            const Text('Broadcast a message to all students or a specific department.'),
            const SizedBox(height: AppSpacing.xxxl),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Notification Title',
                hintText: 'e.g., Urgent: Exam Postponed',
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            const TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Message Body',
                hintText: 'Type your message here...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            AppButton(
              text: 'Send Broadcast',
              icon: Icons.send_rounded,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
