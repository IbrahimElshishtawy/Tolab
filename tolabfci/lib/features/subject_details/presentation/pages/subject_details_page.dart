import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';
import '../widgets/group_tab.dart';
import '../widgets/lectures_tab.dart';
import '../widgets/quizzes_tab.dart';
import '../widgets/sections_tab.dart';
import '../widgets/subject_details_header.dart';
import '../widgets/summaries_tab.dart';
import '../widgets/tasks_tab.dart';

class SubjectDetailsPage extends ConsumerStatefulWidget {
  const SubjectDetailsPage({
    super.key,
    required this.subjectId,
  });

  final String subjectId;

  @override
  ConsumerState<SubjectDetailsPage> createState() => _SubjectDetailsPageState();
}

class _SubjectDetailsPageState extends ConsumerState<SubjectDetailsPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final subjectAsync = ref.watch(subjectByIdProvider(widget.subjectId));

    return SafeArea(
      child: AdaptivePageContainer(
        child: subjectAsync.when(
          data: (subject) => ListView(
            children: [
              SubjectDetailsHeader(subject: subject),
              const SizedBox(height: AppSpacing.lg),
              AppSegmentedControl<int>(
                groupValue: _selectedIndex,
                onValueChanged: (value) => setState(() => _selectedIndex = value),
                children: const {
                  0: Padding(padding: EdgeInsets.all(8), child: Text('Lectures')),
                  1: Padding(padding: EdgeInsets.all(8), child: Text('Sections')),
                  2: Padding(padding: EdgeInsets.all(8), child: Text('Quizzes')),
                  3: Padding(padding: EdgeInsets.all(8), child: Text('Tasks')),
                  4: Padding(padding: EdgeInsets.all(8), child: Text('Summaries')),
                  5: Padding(padding: EdgeInsets.all(8), child: Text('Group')),
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildContent(),
            ],
          ),
          loading: () => const LoadingWidget(label: 'Loading subject...'),
          error: (error, stackTrace) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return LecturesTab(subjectId: widget.subjectId);
      case 1:
        return SectionsTab(subjectId: widget.subjectId);
      case 2:
        return QuizzesTab(subjectId: widget.subjectId);
      case 3:
        return TasksTab(subjectId: widget.subjectId);
      case 4:
        return SummariesTab(subjectId: widget.subjectId);
      case 5:
        return GroupTab(subjectId: widget.subjectId);
      default:
        return const SizedBox.shrink();
    }
  }
}
