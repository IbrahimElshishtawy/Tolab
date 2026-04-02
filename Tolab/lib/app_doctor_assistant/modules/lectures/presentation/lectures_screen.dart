import '../../../core/navigation/app_routes.dart';
import '../../../presentation/widgets/doctor_assistant_content_form.dart';

class LecturesScreen extends DoctorAssistantContentFormScreen {
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
      );
}
