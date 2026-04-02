import '../../../core/navigation/app_routes.dart';
import '../../../presentation/widgets/doctor_assistant_content_form.dart';

class SectionContentScreen extends DoctorAssistantContentFormScreen {
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
      );
}
