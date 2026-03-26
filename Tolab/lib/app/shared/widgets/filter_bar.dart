import 'package:flutter/material.dart';

import '../../core/spacing/app_spacing.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.searchHint,
    this.onSearchChanged,
    this.trailing = const [],
  });

  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        ...trailing,
      ],
    );
  }
}
