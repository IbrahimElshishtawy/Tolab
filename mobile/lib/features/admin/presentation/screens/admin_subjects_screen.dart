import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';

class AdminSubjectsScreen extends StatelessWidget {
  const AdminSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Subjects',
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.l),
        itemCount: 8,
        itemBuilder: (context, index) => AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Subject ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('SUB${100 + index}'),
            trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );
  }
}
