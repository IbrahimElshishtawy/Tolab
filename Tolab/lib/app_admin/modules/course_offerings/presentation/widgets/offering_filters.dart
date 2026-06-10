import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/course_offering_model.dart';

class OfferingFilters extends StatefulWidget {
  const OfferingFilters({
    super.key,
    required this.filters,
    required this.semesterOptions,
    required this.departments,
    required this.isMutating,
    required this.onSearchChanged,
    required this.onSemesterChanged,
    required this.onDepartmentChanged,
    required this.onStatusChanged,
    required this.onReset,
    required this.onCreate,
  });

  final CourseOfferingsFilters filters;
  final List<String> semesterOptions;
  final List<CourseOfferingLookupOption> departments;
  final bool isMutating;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onSemesterChanged;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<CourseOfferingStatus?> onStatusChanged;
  final VoidCallback onReset;
  final VoidCallback onCreate;

  @override
  State<OfferingFilters> createState() => _OfferingFiltersState();
}

class _OfferingFiltersState extends State<OfferingFilters> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filters.searchQuery);
  }

  @override
  void didUpdateWidget(covariant OfferingFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters.searchQuery != widget.filters.searchQuery &&
        _searchController.text != widget.filters.searchQuery) {
      _searchController.text = widget.filters.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 980;
          final controls = <Widget>[
            _DropdownField<String>(
              label: context.l10n.byValue('Semester'),
              value: widget.filters.semester,
              items: widget.semesterOptions,
              itemLabel: (value) => context.l10n.byValue(value),
              onChanged: widget.onSemesterChanged,
            ),
            _DropdownField<String>(
              label: context.l10n.byValue('Department'),
              value: widget.filters.departmentId,
              items: widget.departments.map((item) => item.id).toList(),
              itemLabel: (value) {
                final option = widget.departments.firstWhere(
                  (item) => item.id == value,
                );
                return context.l10n.byValue(option.label);
              },
              onChanged: widget.onDepartmentChanged,
            ),
            _DropdownField<CourseOfferingStatus>(
              label: context.l10n.byValue('Status'),
              value: widget.filters.status,
              items: CourseOfferingStatus.values,
              itemLabel: (value) => context.l10n.byValue(value.label),
              onChanged: widget.onStatusChanged,
            ),
          ];

          return Column(
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _searchField(context),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: controls
                          .map((item) => SizedBox(width: 240, child: item))
                          .toList(growable: false),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _actions(context),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _searchField(context)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 3,
                      child: Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        alignment: WrapAlignment.end,
                        children: controls
                            .map((item) => SizedBox(width: 180, child: item))
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _actions(context),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: widget.onSearchChanged,
      decoration: InputDecoration(
        labelText: context.l10n.byValue('Search offerings'),
        hintText: context.l10n.byValue('Subject, code, section, doctor'),
        prefixIcon: const Icon(Icons.search_rounded),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        PremiumButton(
          label: context.l10n.byValue('Reset'),
          icon: Icons.refresh_rounded,
          isSecondary: true,
          onPressed: widget.onReset,
        ),
        PremiumButton(
          label: widget.isMutating
              ? context.l10n.byValue('Saving...')
              : context.l10n.byValue('New offering'),
          icon: Icons.add_rounded,
          onPressed: widget.isMutating ? null : widget.onCreate,
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
  });

  final String label;
  final List<T> items;
  final String Function(T value) itemLabel;
  final T? value;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T?>(
      initialValue: value,
      isExpanded: true,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<T?>(
          value: null,
          child: Text(context.l10n.byValue('All')),
        ),
        ...items.map(
          (item) =>
              DropdownMenuItem<T?>(value: item, child: Text(itemLabel(item))),
        ),
      ],
    );
  }
}
