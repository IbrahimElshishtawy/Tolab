import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../redux/app_state.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar_widget.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/business_widgets.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';
import '../../../../core/ui/tokens/color_tokens.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.authState.email,
      builder: (context, email) {
        final userName = email?.split('@').first ?? 'Doctor';

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(
                    userName: 'Dr. ${userName.toUpperCase()}',
                    role: 'Professor',
                  ),
                  const SearchBarWidget(
                      hintText: 'Search subjects or students...'),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            label: 'Total Students',
                            value: '315',
                            icon: Icons.people_alt_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: StatTile(
                            label: 'Pending Grades',
                            value: '24',
                            icon: Icons.pending_actions_rounded,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    child: SectionHeader(title: 'Course Overview'),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final courses = ['Software Engineering', 'Database Systems', 'Operating Systems'];
                      final codes = ['CS311', 'IS212', 'CS221'];
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(AppSpacing.s),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.class_rounded, color: AppColors.primary),
                          ),
                          title: Text(courses[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${codes[index]} • ${120 - (index * 15)} Students'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    child: SectionHeader(title: 'Quick Management'),
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    mainAxisSpacing: AppSpacing.m,
                    crossAxisSpacing: AppSpacing.m,
                    childAspectRatio: 1.5,
                    children: [
                      _buildQuickAction(context, 'Broadcast', Icons.campaign_rounded, AppColors.secondary),
                      _buildQuickAction(context, 'Curriculum', Icons.menu_book_rounded, AppColors.success),
                      _buildQuickAction(context, 'Assessments', Icons.quiz_rounded, AppColors.warning),
                      _buildQuickAction(context, 'Schedule', Icons.event_note_rounded, AppColors.info),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color) {
    return AppCard(
      onTap: () {},
      color: color.withOpacity(0.05),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
