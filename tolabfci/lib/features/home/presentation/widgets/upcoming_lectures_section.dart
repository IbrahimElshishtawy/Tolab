import 'package:flutter/material.dart';

import '../../../../core/models/subject_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';

class UpcomingLecturesSection extends StatelessWidget {
  const UpcomingLecturesSection({
    super.key,
    required this.lectures,
  });

  final List<LectureItem> lectures;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const AppSectionHeader(
            title: 'Upcoming lectures',
            subtitle: 'Live sessions and scheduled meetings',
          ),
          const SizedBox(height: AppSpacing.md),
          ...lectures.map(
            (lecture) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Icon(
                  lecture.isOnline ? Icons.videocam_outlined : Icons.location_on_outlined,
                ),
              ),
              title: Text(lecture.title),
              subtitle: Text(lecture.scheduleLabel),
              trailing: Text(lecture.isOnline ? 'Online' : 'On campus'),
            ),
          ),
        ],
      ),
    );
  }
}

