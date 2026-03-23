import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';

class AdminBroadcastNotificationsScreen extends StatefulWidget {
  const AdminBroadcastNotificationsScreen({super.key});

  @override
  State<AdminBroadcastNotificationsScreen> createState() => _AdminBroadcastNotificationsScreenState();
}

class _AdminBroadcastNotificationsScreenState extends State<AdminBroadcastNotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Broadcast',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Send Push Notification', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: AppSpacing.s),
              const Text('Broadcast a message to all students or a specific department.'),
              const SizedBox(height: AppSpacing.xxxl),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Notification Title',
                  hintText: 'e.g., Urgent: Exam Postponed',
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: AppSpacing.l),
              TextFormField(
                controller: _bodyController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message Body',
                  hintText: 'Type your message here...',
                  alignLabelWithHint: true,
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Body is required' : null,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                text: 'Send Broadcast',
                icon: Icons.send_rounded,
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Broadcast sent successfully')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
