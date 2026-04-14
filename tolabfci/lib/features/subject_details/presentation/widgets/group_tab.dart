import 'package:flutter/material.dart';

import '../../../group/presentation/widgets/subject_group_section.dart';

class GroupTab extends StatelessWidget {
  const GroupTab({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context) {
    return SubjectGroupSection(subjectId: subjectId);
  }
}
