import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/state/async_state.dart';
import '../../../../models/doctor_assistant_models.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../../presentation/widgets/quick_stats_section.dart';
import '../../state/quizzes_state.dart';
import '../models/quizzes_workspace_models.dart';
import 'quiz_builder_form.dart';
import 'quizzes_overview_panel.dart';

class QuizzesWorkspacePage extends StatefulWidget {
  const QuizzesWorkspacePage({
    super.key,
    required this.quizzesState,
    required this.workspaceData,
    required this.subjects,
    required this.onReload,
    required this.onSaveQuiz,
    required this.onPublishQuiz,
    required this.onCloseQuiz,
    required this.onDuplicateQuiz,
    this.initialEditQuizId,
  });

  final QuizzesState quizzesState;
  final QuizzesWorkspaceData workspaceData;
  final List<TeachingSubject> subjects;
  final VoidCallback onReload;
  final ValueChanged<Map<String, dynamic>> onSaveQuiz;
  final ValueChanged<int> onPublishQuiz;
  final ValueChanged<int> onCloseQuiz;
  final ValueChanged<int> onDuplicateQuiz;
  final int? initialEditQuizId;

  @override
  State<QuizzesWorkspacePage> createState() => _QuizzesWorkspacePageState();
}

class _QuizzesWorkspacePageState extends State<QuizzesWorkspacePage> {
  final GlobalKey<QuizBuilderFormState> _formKey =
      GlobalKey<QuizBuilderFormState>();
  final GlobalKey _formAnchorKey = GlobalKey();
  int? _appliedInitialEditId;

  @override
  void didUpdateWidget(covariant QuizzesWorkspacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyInitialEditIfNeeded();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyInitialEditIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1180;

        final overviewPanel = QuizzesOverviewPanel(
          data: widget.workspaceData,
          status: widget.quizzesState.status,
          errorMessage: widget.quizzesState.error,
          onRetry: widget.onReload,
          onCreateQuiz: _focusBuilder,
          onPreviewQuiz: (quiz) => context.go(AppRoutes.quizPreview(quiz.id)),
          onEditQuiz: _handleEditQuiz,
          onPrimaryAction: _handlePrimaryAction,
          onResultsQuiz: (quiz) => context.go(AppRoutes.quizResults(quiz.id)),
          onDuplicateQuiz: _handleDuplicateQuiz,
        );

        final builderPanel = KeyedSubtree(
          key: _formAnchorKey,
          child: QuizBuilderForm(
            key: _formKey,
            subjects: widget.subjects,
            onSaveQuiz: widget.onSaveQuiz,
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuickActionsSection(actions: widget.workspaceData.quickActions),
            const SizedBox(height: AppSpacing.lg),
            QuickStatsSection(
              title: 'Quiz Quick Stats',
              subtitle:
                  'A fast summary of the publishing queue, live windows, completion, and pass trend.',
              metrics: widget.workspaceData.metrics,
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: isWide
                  ? Row(
                      key: const ValueKey('quizzes-wide'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: overviewPanel),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(flex: 5, child: builderPanel),
                      ],
                    )
                  : Column(
                      key: const ValueKey('quizzes-stacked'),
                      children: [
                        overviewPanel,
                        const SizedBox(height: AppSpacing.lg),
                        builderPanel,
                      ],
                    ),
            ),
            if (widget.quizzesState.status == ViewStatus.loading &&
                widget.workspaceData.quizzes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const LinearProgressIndicator(minHeight: 3),
            ],
          ],
        );
      },
    );
  }

  void _applyInitialEditIfNeeded() {
    final targetId = widget.initialEditQuizId;
    if (targetId == null || _appliedInitialEditId == targetId) {
      return;
    }
    QuizWorkspaceItem? quiz;
    for (final item in widget.workspaceData.quizzes) {
      if (item.id == targetId) {
        quiz = item;
        break;
      }
    }
    if (quiz == null) {
      return;
    }
    final targetQuiz = quiz;
    _appliedInitialEditId = targetId;
    _focusBuilder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.prefillFromQuiz(targetQuiz);
    });
  }

  void _focusBuilder() {
    final contextForForm = _formAnchorKey.currentContext;
    if (contextForForm == null) {
      return;
    }
    Scrollable.ensureVisible(
      contextForForm,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _handleEditQuiz(QuizWorkspaceItem quiz) {
    _focusBuilder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.prefillFromQuiz(quiz);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loaded ${quiz.title} into the quiz builder.')),
      );
    });
  }

  void _handlePrimaryAction(QuizWorkspaceItem quiz) {
    if (quiz.isOpen) {
      widget.onCloseQuiz(quiz.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${quiz.title} has been closed.')));
      return;
    }
    widget.onPublishQuiz(quiz.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${quiz.title} is ready for students.')),
    );
  }

  void _handleDuplicateQuiz(QuizWorkspaceItem quiz) {
    widget.onDuplicateQuiz(quiz.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${quiz.title} was duplicated into a draft copy.'),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.actions});

  final List<WorkspaceQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Quiz Actions',
      subtitle:
          'Open the adjacent workflows usually needed before or after a quiz window.',
      child: DoctorAssistantQuickActionGrid(actions: actions),
    );
  }
}
