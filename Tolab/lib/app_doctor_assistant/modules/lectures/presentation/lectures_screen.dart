import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/models/content_models.dart';
import '../../../state/app_state.dart';
import '../state/lectures_actions.dart';
import '../state/lectures_state.dart';
import '../../../presentation/widgets/doctor_assistant_content_form.dart';

class LecturesScreen extends DoctorAssistantContentFormScreen<LectureModel> {
  const LecturesScreen({super.key})
    : super(
        route: AppRoutes.lectures,
        pageTitle: 'Add Lecture',
        pageSubtitle:
            'Use the admin-aligned form surface to add lecture metadata, timing, and scope.',
        primaryActionLabel: 'Save lecture',
        subjectHint: 'Algorithms / Data Structures / Software Engineering',
        scopeHint: 'Lecture Group A or all enrolled students',
        scheduleHint: 'Sun 09:00 - 11:00 • Hall B2',
        stateSelector: _stateSelector,
        onLoad: _onLoad,
        onSave: _onSave,
        itemTitle: _itemTitle,
        itemSubtitle: _itemSubtitle,
        itemMeta: _itemMeta,
        itemStatusLabel: _itemStatus,
        itemIcon: Icons.co_present_rounded,
        existingPanelTitle: 'Existing lectures',
        existingPanelSubtitle:
            'Review current lecture records and add the next delivery block without leaving the page.',
        emptyTitle: 'No lectures yet',
        emptySubtitle:
            'Create the first lecture draft to populate the local teaching flow.',
      );
}

LecturesState _stateSelector(DoctorAssistantAppState state) => state.lecturesState;

void _onLoad(Store<DoctorAssistantAppState> store) =>
    store.dispatch(LoadLecturesAction());

void _onSave(Store<DoctorAssistantAppState> store, Map<String, dynamic> payload) =>
    store.dispatch(SaveLectureAction(payload));

String _itemTitle(LectureModel item) => item.title;

String _itemSubtitle(LectureModel item) =>
    'Week ${item.weekNumber} - ${item.instructorName}';

String _itemMeta(LectureModel item) => item.isPublished
    ? 'Published in the local workspace'
    : 'Draft item in mock storage';

String _itemStatus(LectureModel item) => item.isPublished ? 'Published' : 'Draft';
