import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/models/session_user.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) return const SizedBox.shrink();
        final repository = DoctorAssistantMockRepository.instance;
        final snapshot = repository.homeFor(user);

        return DoctorAssistantShell(
          user: user,
          activeRoute: '/workspace/home',
          child: DoctorAssistantPageScaffold(
            title: user.isDoctor ? 'Doctor Home' : 'Assistant Home',
            subtitle:
                'Premium academic workspace with the same shell, density, and interaction model as admin.',
            breadcrumbs: const ['Workspace', 'Home'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorAssistantPanel(
                  title: 'Today',
                  subtitle: snapshot.dateLabel,
                  child: DoctorAssistantSummaryStrip(metrics: snapshot.metrics),
                ),
                const SizedBox(height: 11.2),
                DoctorAssistantPanel(
                  title: 'Upcoming',
                  subtitle:
                      'Lectures, sections, and quizzes that need attention next.',
                  child: Column(
                    children: [
                      for (final item in snapshot.upcoming) ...[
                        DoctorAssistantItemCard(
                          icon: item.icon,
                          title: item.title,
                          subtitle: item.subtitle,
                          meta: item.timeLabel,
                          statusLabel: item.statusLabel,
                        ),
                        if (item != snapshot.upcoming.last)
                          const SizedBox(height: 11.2),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 11.2),
                DoctorAssistantPanel(
                  title: 'Quick Actions',
                  subtitle:
                      'Use the exact admin-styled action cards to add new academic content.',
                  child: DoctorAssistantQuickActionGrid(
                    actions: snapshot.quickActions,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
