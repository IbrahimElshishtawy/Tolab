import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/models/content_models.dart';
import '../../../state/app_state.dart';
import '../state/quizzes_actions.dart';
import '../state/quizzes_state.dart';
import '../../../presentation/widgets/doctor_assistant_content_form.dart';

class QuizzesScreen extends DoctorAssistantContentFormScreen<QuizModel> {
  const QuizzesScreen({super.key})
    : super(
        route: AppRoutes.quizzes,
        pageTitle: 'Add Quiz',
        pageSubtitle:
            'Configure a quiz window, scope, and timing using the exact same form density and buttons.',
        primaryActionLabel: 'Save quiz',
        subjectHint: 'Software Engineering / AI / Algorithms',
        scopeHint: 'Level 4 cohort / Section groups B1-B4',
        scheduleHint: 'Tue 10:30 • 90 min',
        stateSelector: _stateSelector,
        onLoad: _onLoad,
        onSave: _onSave,
        itemTitle: _itemTitle,
        itemSubtitle: _itemSubtitle,
        itemMeta: _itemMeta,
        itemStatusLabel: _itemStatus,
        itemIcon: Icons.quiz_rounded,
        existingPanelTitle: 'Existing quizzes',
        existingPanelSubtitle:
            'Create timed assessments while keeping the current local quiz set visible.',
        emptyTitle: 'No quizzes yet',
        emptySubtitle:
            'Add a mock quiz to simulate the assessment flow.',
      );
}

QuizzesState _stateSelector(DoctorAssistantAppState state) => state.quizzesState;

void _onLoad(Store<DoctorAssistantAppState> store) =>
    store.dispatch(LoadQuizzesAction());

void _onSave(Store<DoctorAssistantAppState> store, Map<String, dynamic> payload) =>
    store.dispatch(SaveQuizAction(payload));

String _itemTitle(QuizModel item) => item.title;

String _itemSubtitle(QuizModel item) => '${item.ownerName} - ${item.quizType}';

String _itemMeta(QuizModel item) => item.quizDate;

String _itemStatus(QuizModel item) => item.isPublished ? 'Published' : 'Draft';
