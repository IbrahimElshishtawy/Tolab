import '../../../core/navigation/app_routes.dart';
import '../../../presentation/widgets/doctor_assistant_content_form.dart';

class TasksScreen extends DoctorAssistantContentFormScreen {
  const TasksScreen({super.key})
    : super(
        route: AppRoutes.tasks,
        pageTitle: 'Add Task',
        pageSubtitle:
            'Publish a task or assignment milestone using the shared admin-style form treatment.',
        primaryActionLabel: 'Save task',
        subjectHint: 'Algorithms / Software Engineering / AI',
        scopeHint: 'All lecture groups / project teams / section D1',
        scheduleHint: 'Due Thu 17 Apr • 23:59',
      );
}
