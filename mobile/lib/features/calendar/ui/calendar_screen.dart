import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String _selectedWeek = 'ALL';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Timetable',
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'ALL', label: Text('ALL')),
              ButtonSegment(value: 'ODD', label: Text('ODD')),
              ButtonSegment(value: 'EVEN', label: Text('EVEN')),
            ],
            selected: {_selectedWeek},
            onSelectionChanged: (val) => setState(() => _selectedWeek = val.first),
          ),
        ),
      ],
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.l),
        itemCount: 5, // Mocking days
        itemBuilder: (context, index) {
          final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                child: Text(days[index], style: Theme.of(context).textTheme.titleLarge),
              ),
              AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.l),
                child: Column(
                  children: [
                    _buildEventItem(context, '08:00 AM', 'Software Engineering', 'Lecture - Hall 3'),
                    Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                    _buildEventItem(context, '10:00 AM', 'Database Systems', 'Section - Lab 2'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, String time, String subject, String details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 80,
            child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(details, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
