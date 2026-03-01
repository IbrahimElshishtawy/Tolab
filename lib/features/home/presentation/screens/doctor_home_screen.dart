import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tolab_fci/redux/state/app_state.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/course_card.dart';
import '../widgets/quick_action_card.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.authState.email,
      builder: (context, email) {
        final userName = email?.split('@').first ?? 'Doctor';

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(
                    userName: 'Dr. ${userName.toUpperCase()}',
                    role: 'Professor',
                  ),
                  const SearchBarWidget(
                      hintText: 'Search subjects or students...'),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Courses',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 20),
                      children: [
                        CourseCard(
                          courseName: 'Software Engineering',
                          courseCode: 'CS311',
                          studentsCount: '120 Students',
                          onTap: () {},
                        ),
                        CourseCard(
                          courseName: 'Database Systems',
                          courseCode: 'IS212',
                          studentsCount: '85 Students',
                          onTap: () {},
                        ),
                        CourseCard(
                          courseName: 'Operating Systems',
                          courseCode: 'CS221',
                          studentsCount: '110 Students',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Doctor Actions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.3,
                    children: [
                      QuickActionCard(
                        title: 'Post\nAnnouncement',
                        icon: Icons.campaign_outlined,
                        color: Colors.orange,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Upload\nMaterials',
                        icon: Icons.upload_file_outlined,
                        color: Colors.blue,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'View\nGrades',
                        icon: Icons.assignment_turned_in_outlined,
                        color: Colors.green,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Attendance',
                        icon: Icons.how_to_reg_outlined,
                        color: Colors.purple,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
