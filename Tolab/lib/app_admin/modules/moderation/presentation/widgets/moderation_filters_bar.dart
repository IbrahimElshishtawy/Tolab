import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

class ModerationFiltersBar extends StatefulWidget {
  const ModerationFiltersBar({
    super.key,
    required this.searchHint,
    required this.searchValue,
    required this.onSearchChanged,
    required this.statusOptions,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.secondaryLabel,
    required this.secondaryOptions,
    required this.selectedSecondary,
    required this.onSecondaryChanged,
    required this.dateOptions,
    required this.selectedDate,
    required this.onDateChanged,
    this.trailing = const <Widget>[],
  });

  final String searchHint;
  final String searchValue;
  final ValueChanged<String> onSearchChanged;
  final List<String> statusOptions;
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;
  final String secondaryLabel;
  final List<String> secondaryOptions;
  final String selectedSecondary;
  final ValueChanged<String> onSecondaryChanged;
  final List<String> dateOptions;
  final String selectedDate;
  final ValueChanged<String> onDateChanged;
  final List<Widget> trailing;

  @override
  State<ModerationFiltersBar> createState() => _ModerationFiltersBarState();
}

class _ModerationFiltersBarState extends State<ModerationFiltersBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchValue);
  }

  @override
  void didUpdateWidget(covariant ModerationFiltersBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchValue != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.searchValue,
        selection: TextSelection.collapsed(offset: widget.searchValue.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final searchField = TextField(
            controller: _controller,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: widget.searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: const Icon(Icons.tune_rounded),
            ),
          );

          final controls = <Widget>[
            _FilterDropdown(
              label: 'Status',
              value: widget.selectedStatus,
              options: widget.statusOptions,
              onChanged: widget.onStatusChanged,
              width: constraints.maxWidth < 560 ? double.infinity : 180,
            ),
            _FilterDropdown(
              label: widget.secondaryLabel,
              value: widget.selectedSecondary,
              options: widget.secondaryOptions,
              onChanged: widget.onSecondaryChanged,
              width: constraints.maxWidth < 560 ? double.infinity : 180,
            ),
            _FilterDropdown(
              label: 'Date',
              value: widget.selectedDate,
              options: widget.dateOptions,
              onChanged: widget.onDateChanged,
              width: constraints.maxWidth < 560 ? double.infinity : 180,
            ),
            ...widget.trailing,
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchField,
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: controls,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.width,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        initialValue: options.contains(value) ? value : options.first,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(growable: false),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}
