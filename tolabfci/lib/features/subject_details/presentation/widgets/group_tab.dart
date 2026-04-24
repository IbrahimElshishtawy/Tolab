import 'package:flutter/material.dart';

import '../../../group/presentation/pages/course_community_page.dart';

class GroupTab extends StatelessWidget {
  const GroupTab({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context) {
    return CourseCommunityPage(subjectId: subjectId, embedded: true);
  }
}
