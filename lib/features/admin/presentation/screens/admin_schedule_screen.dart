import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';

class AdminScheduleScreen extends StatelessWidget {
  const AdminScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Manage Schedule',
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.l),
        itemCount: 5,
        itemBuilder: (context, index) {
          final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: days[index]),
              AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.l),
                child: Column(
                  children: [
                    _buildEditableEvent(context, '08:00 AM', 'Software Engineering'),
                    const Divider(height: AppSpacing.xxl),
                    _buildEditableEvent(context, '10:00 AM', 'Database Systems'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_task),
      ),
    );
  }

  Widget _buildEditableEvent(BuildContext context, String time, String subject) {
    return Row(
      children: [
        Text(time, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(width: AppSpacing.l),
        Expanded(child: Text(subject)),
        IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () {}),
        IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () {}),
      ],
    );
  }
}
