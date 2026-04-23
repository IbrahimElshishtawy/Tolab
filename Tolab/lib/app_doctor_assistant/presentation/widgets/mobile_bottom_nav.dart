import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../core/navigation/navigation_items.dart';

class DoctorAssistantMobileBottomNav extends StatelessWidget {
  const DoctorAssistantMobileBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<DoctorAssistantNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<DoctorAssistantNavigationItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 72,
      selectedIndex: selectedIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: items
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon),
              label: context.l10n.byValue(item.label),
            ),
          )
          .toList(growable: false),
      onDestinationSelected: (index) => onSelected(items[index]),
    );
  }
}
