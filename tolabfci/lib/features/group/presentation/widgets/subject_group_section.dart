import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../../chat/presentation/widgets/chat_panel.dart';
import '../../../subject_details/presentation/widgets/community_feed.dart';

class SubjectGroupSection extends StatefulWidget {
  const SubjectGroupSection({super.key, required this.subjectId});

  final String subjectId;

  @override
  State<SubjectGroupSection> createState() => _SubjectGroupSectionState();
}

class _SubjectGroupSectionState extends State<SubjectGroupSection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSegmentedControl<int>(
          groupValue: _selectedIndex,
          onValueChanged: (value) => setState(() => _selectedIndex = value),
          children: const {
            0: Padding(padding: EdgeInsets.all(8), child: Text('المنشورات')),
            1: Padding(padding: EdgeInsets.all(8), child: Text('الدردشة')),
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: _selectedIndex == 0
                  ? CommunityFeed(subjectId: widget.subjectId)
                  : ChatPanel(subjectId: widget.subjectId),
            ),
          ),
        ),
      ],
    );
  }
}
