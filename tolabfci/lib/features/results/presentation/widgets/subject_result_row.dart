import 'package:flutter/material.dart';

import '../../../../core/models/result_item.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';

class SubjectResultRow extends StatelessWidget {
  const SubjectResultRow({super.key, required this.result});

  final SubjectResult result;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(child: Text(result.subjectName)),
          Expanded(child: Text('${result.totalGrade}')),
          Expanded(child: Text(result.letterGrade)),
          AppBadge(label: result.status),
        ],
      ),
    );
  }
}
