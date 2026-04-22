import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/models/content_models.dart';
import '../../../state/app_state.dart';
import '../state/section_content_actions.dart';
import '../state/section_content_state.dart';
import '../../../presentation/widgets/doctor_assistant_content_form.dart';

class SectionContentScreen
    extends DoctorAssistantContentFormScreen<SectionContentModel> {
  const SectionContentScreen({super.key})
    : super(
        route: AppRoutes.sectionContent,
        pageTitle: 'Add Section',
        pageSubtitle:
            'Create lab, tutorial, or assistant-led section content with the same dense admin form language.',
        primaryActionLabel: 'Save section',
        subjectHint: 'Algorithms / Data Structures / AI',
        scopeHint: 'Section A1 / Lab D2 / Tutorial Track C',
        scheduleHint: 'Mon 12:00 - 13:30 • Lab C1',
        stateSelector: _stateSelector,
        onLoad: _onLoad,
        onSave: _onSave,
        itemTitle: _itemTitle,
        itemSubtitle: _itemSubtitle,
        itemMeta: _itemMeta,
        itemStatusLabel: _itemStatus,
        itemIcon: Icons.widgets_rounded,
        existingPanelTitle: 'Existing sections',
        existingPanelSubtitle:
            'Keep section and tutorial content visible while drafting the next mock item.',
        emptyTitle: 'No sections yet',
        emptySubtitle:
            'Save a section draft to start the local assistant workflow.',
      );
}

SectionContentState _stateSelector(DoctorAssistantAppState state) =>
    state.sectionContentState;

void _onLoad(Store<DoctorAssistantAppState> store) =>
    store.dispatch(LoadSectionContentAction());

void _onSave(Store<DoctorAssistantAppState> store, Map<String, dynamic> payload) =>
    store.dispatch(SaveSectionContentAction(payload));

String _itemTitle(SectionContentModel item) => item.title;

String _itemSubtitle(SectionContentModel item) =>
    'Week ${item.weekNumber} - ${item.assistantName}';

String _itemMeta(SectionContentModel item) => item.isPublished
    ? 'Published to section groups'
    : 'Draft item in mock storage';

String _itemStatus(SectionContentModel item) =>
    item.isPublished ? 'Published' : 'Draft';
