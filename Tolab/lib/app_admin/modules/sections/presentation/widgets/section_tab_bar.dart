import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/section_management_models.dart';
import '../design/section_management_tokens.dart';
import 'section_management_primitives.dart';

class SectionTabBar extends StatelessWidget {
  const SectionTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  final SectionDetailTab activeTab;
  final ValueChanged<SectionDetailTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: SectionManagementPalette.frostedSurface(
        context,
        lightAlpha: 0.72,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final tab in SectionDetailTab.values)
            SectionSegmentChip(
              label: context.l10n.byValue(_tabLabel(tab)),
              selected: activeTab == tab,
              onTap: () => onTabChanged(tab),
            ),
        ],
      ),
    );
  }

  String _tabLabel(SectionDetailTab tab) => switch (tab) {
        SectionDetailTab.overview => 'Overview',
        SectionDetailTab.students => 'Students',
        SectionDetailTab.schedule => 'Schedule',
        SectionDetailTab.subjects => 'Subjects',
        SectionDetailTab.staff => 'Staff',
      };
}

