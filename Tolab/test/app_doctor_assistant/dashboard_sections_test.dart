import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tolab_fci/app_doctor_assistant/core/models/dashboard_models.dart';
import 'package:tolab_fci/app_doctor_assistant/modules/dashboard/presentation/theme/dashboard_theme_tokens.dart';
import 'package:tolab_fci/app_doctor_assistant/modules/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:tolab_fci/app_doctor_assistant/modules/dashboard/presentation/widgets/students_attention_section.dart';

void main() {
  testWidgets('dashboard sections render actionable content', (tester) async {
    final quickActions = [
      const DashboardQuickAction(
        id: 'add_lecture',
        label: 'Add Lecture',
        description: 'Publish lecture content before the next session.',
        route: '/workspace/lectures',
        permission: 'lectures.create',
      ),
    ];
    final attention = DashboardStudentsAttention(
      count: 1,
      items: const [
        DashboardStudentAttentionItem(
          studentId: 7,
          name: 'Omar Ali',
          reason: 'Missed 2 task submissions',
          severity: 'HIGH',
          ctaLabel: 'Review',
          route: '/workspace/subjects/1',
          details: ['Missed 2 task submissions'],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Builder(
          builder: (context) {
            DashboardThemeTokens.of(context);
            return Scaffold(
              body: ListView(
                children: [
                  QuickActionsSection(
                    actions: quickActions,
                    onOpenRoute: (_) {},
                  ),
                  StudentsAttentionSection(
                    section: attention,
                    onOpenRoute: (_) {},
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Add Lecture'), findsOneWidget);
    expect(find.text('Students Needing Attention'), findsOneWidget);
    expect(find.text('Omar Ali'), findsOneWidget);
    expect(find.text('HIGH'), findsOneWidget);
  });
}
