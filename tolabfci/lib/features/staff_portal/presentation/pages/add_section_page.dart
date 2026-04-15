import 'package:flutter/widgets.dart';

import '../../domain/models/staff_portal_models.dart';
import 'add_lecture_page.dart';

class AddSectionPage extends StatelessWidget {
  const AddSectionPage({
    super.key,
    required this.subjectId,
    this.initialSession,
  });

  final String subjectId;
  final StaffSessionLink? initialSession;

  @override
  Widget build(BuildContext context) {
    return SessionEditorPage(
      subjectId: subjectId,
      kind: StaffSessionKind.section,
      initialSession: initialSession,
    );
  }
}
