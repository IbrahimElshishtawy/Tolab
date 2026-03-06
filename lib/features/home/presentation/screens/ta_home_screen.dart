import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tolab_fci/redux/state/app_state.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/course_card.dart';
import '../widgets/quick_action_card.dart';

class TaHomeScreen extends StatelessWidget {
  const TaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.authState.email,
      builder: (context, email) {
        final userName = email?.split('@').first ?? 'TA';

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(
                    userName: userName.toUpperCase(),
                    role: 'Teaching Assistant',
                  ),
                  const SearchBarWidget(hintText: 'Search labs or students...'),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Upcoming Lab Sessions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                          courseName: 'Intro to Programming Lab',
                          courseCode: 'CS101 - Lab',
                          studentsCount: '30 Students',
                          onTap: () {},
                        ),
                        CourseCard(
                          courseName: 'Data Structures Lab',
                          courseCode: 'CS201 - Lab',
                          studentsCount: '25 Students',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'TA Dashboard',
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
                        title: 'Grade\nAssignments',
                        icon: Icons.grade_outlined,
                        color: Colors.teal,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Student\nQueries',
                        icon: Icons.question_answer_outlined,
                        color: Colors.indigo,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Lab\nAttendance',
                        icon: Icons.playlist_add_check_outlined,
                        color: Colors.deepOrange,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Office\nHours',
                        icon: Icons.event_available_outlined,
                        color: Colors.brown,
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
