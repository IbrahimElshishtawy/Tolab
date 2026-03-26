import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../shared/models/academic_models.dart';
import '../../../shared/tables/admin_data_table.dart';
import '../../../shared/widgets/management_page.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/course_offerings_state.dart';

class CourseOfferingsScreen extends StatelessWidget {
  const CourseOfferingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CourseOfferingsState>(
      onInit: (store) => store.dispatch(LoadCourseOfferingsAction()),
      converter: (store) => store.state.courseOfferingsState,
      builder: (context, state) {
        return ManagementPage(
          title: 'Course Offerings',
          subtitle:
              'Connect sections, subjects, doctors, assistants, and seat planning in one view.',
          status: state.status,
          items: state.items,
          searchHint: 'Search offerings',
          headerActions: const [
            PremiumButton(label: 'New offering', icon: Icons.add_chart_rounded),
          ],
          columns: [
            AdminTableColumn<CourseOfferingModel>(
              label: 'Subject',
              cellBuilder: (item) =>
                  Text('${item.subjectCode} • ${item.subjectName}'),
            ),
            AdminTableColumn<CourseOfferingModel>(
              label: 'Section',
              cellBuilder: (item) => Text(item.sectionName),
            ),
            AdminTableColumn<CourseOfferingModel>(
              label: 'Staffing',
              cellBuilder: (item) =>
                  Text('${item.doctorName}\n${item.assistantName}'),
            ),
            AdminTableColumn<CourseOfferingModel>(
              label: 'Capacity',
              cellBuilder: (item) => Text('${item.enrolled}/${item.capacity}'),
            ),
            AdminTableColumn<CourseOfferingModel>(
              label: 'Status',
              cellBuilder: (item) => StatusBadge(item.status),
            ),
          ],
          onRetry: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(LoadCourseOfferingsAction()),
        );
      },
    );
  }
}
