import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) return const SizedBox.shrink();
        final subjects = DoctorAssistantMockRepository.instance.subjectsFor(
          user,
        );

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.subjects,
          child: DoctorAssistantPageScaffold(
            title: 'Subjects',
            subtitle:
                'Subject cards mirror the admin card density and hierarchy while staying mobile-first.',
            breadcrumbs: const ['Workspace', 'Subjects'],
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 720;
                final cardWidth = isCompact
                    ? constraints.maxWidth
                    : (constraints.maxWidth - AppSpacing.md) / 2;

                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final subject in subjects)
                      SizedBox(
                        width: cardWidth,
                        child: DoctorAssistantSubjectCard(
                          subject: subject,
                          onTap: () =>
                              context.go('${AppRoutes.subjects}/${subject.id}'),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
