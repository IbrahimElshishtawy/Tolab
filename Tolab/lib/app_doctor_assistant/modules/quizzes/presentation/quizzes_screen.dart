import '../../../core/navigation/app_routes.dart';
import '../../../presentation/widgets/doctor_assistant_content_form.dart';

class QuizzesScreen extends DoctorAssistantContentFormScreen {
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
        );
}
