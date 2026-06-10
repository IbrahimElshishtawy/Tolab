import 'package:flutter/material.dart';

import 'package:tolab_fci/app/localization/app_localizations.dart';
import 'package:tolab_fci/app_admin/core/spacing/app_spacing.dart';
import 'package:tolab_fci/app_admin/modules/settings/models/settings_models.dart';
import 'package:tolab_fci/app_admin/modules/settings/presentation/settings_screen.dart';
import 'package:tolab_fci/app_admin/modules/settings/widgets/settings_primitives.dart';

class SettingsCalendarSection extends StatelessWidget {
  const SettingsCalendarSection({
    super.key,
    required this.vm,
    required this.width,
    required this.onUpdateBundle,
  });

  final SettingsViewModel vm;
  final double width;
  final void Function(SettingsBundle Function(SettingsBundle) update) onUpdateBundle;

  @override
  Widget build(BuildContext context) {
    final calendar = vm.settingsState.bundle.calendar;
    return Column(
      children: [
        SettingsGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsBlockHeader(
                title: 'Calendar Defaults',
                subtitle:
                    'Control the preferred calendar view and event color mapping.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _fieldWrap(
                width: width,
                children: [
                  SettingsDropdownField<CalendarViewOption>(
                    value: calendar.defaultView,
                    label: 'Default view',
                    items: CalendarViewOption.values,
                    labelBuilder: (value) => value.label,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        calendar: calendar.copyWith(defaultView: value),
                      ),
                    ),
                  ),
                  for (final entry in calendar.typeColors.entries)
                    SettingsColorField(
                      label: '${entry.key} color',
                      color: entry.value,
                      onChanged: (value) {
                        final nextColors = Map<String, Color>.from(
                          calendar.typeColors,
                        )..[entry.key] = value;
                        onUpdateBundle(
                          (b) => b.copyWith(
                            calendar: calendar.copyWith(typeColors: nextColors),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SettingsGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsBlockHeader(
                title: 'Academic Holidays',
                subtitle:
                    'Add holidays and important pauses that should appear in calendar views.',
                trailing: FilledButton.icon(
                  onPressed: () => _addHoliday(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(context.l10n.byValue('Add Holiday')),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (calendar.holidays.isEmpty)
                const SettingsEmptyStateCard(
                  title: 'No holidays configured',
                  subtitle:
                      'Create holidays to highlight non-working academic dates.',
                )
              else
                Column(
                  children: [
                    for (final holiday in calendar.holidays) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    holiday.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.l10n.byValue(holiday.type),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            SettingsDateChip(
                              date: holiday.date,
                              onTap: () =>
                                  _editHolidayDate(context, holiday),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            IconButton(
                              onPressed: () =>
                                  _removeHoliday(holiday),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addHoliday(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );
    if (date == null || !context.mounted) return;

    final nameController = TextEditingController();
    final typeController = TextEditingController(text: 'Academic');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.byValue('Add holiday')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: context.l10n.byValue('Name')),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: context.l10n.byValue('Type')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.byValue('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.byValue('Add')),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (saved != true) return;
    final holiday = HolidayItem(
      id: 'holiday-${DateTime.now().microsecondsSinceEpoch}',
      name: nameController.text.trim().isEmpty
          ? 'Holiday'
          : nameController.text.trim(),
      date: date,
      type: typeController.text.trim().isEmpty
          ? 'Academic'
          : typeController.text.trim(),
    );
    final calendar = vm.settingsState.bundle.calendar;
    onUpdateBundle(
      (b) => b.copyWith(
        calendar: calendar.copyWith(
          holidays: [holiday, ...calendar.holidays],
        ),
      ),
    );
  }

  Future<void> _editHolidayDate(
    BuildContext context,
    HolidayItem holiday,
  ) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      initialDate: holiday.date,
    );
    if (!context.mounted) return;
    if (date == null) return;
    final calendar = vm.settingsState.bundle.calendar;
    onUpdateBundle(
      (b) => b.copyWith(
        calendar: calendar.copyWith(
          holidays: [
            for (final item in calendar.holidays)
              if (item.id == holiday.id) item.copyWith(date: date) else item,
          ],
        ),
      ),
    );
  }

  void _removeHoliday(HolidayItem holiday) {
    final calendar = vm.settingsState.bundle.calendar;
    onUpdateBundle(
      (b) => b.copyWith(
        calendar: calendar.copyWith(
          holidays: [
            for (final item in calendar.holidays)
              if (item.id != holiday.id) item,
          ],
        ),
      ),
    );
  }

  Widget _fieldWrap({required double width, required List<Widget> children}) {
    final tileWidth = width >= 920 ? (width - AppSpacing.md) / 2 : width;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final child in children)
          SizedBox(width: tileWidth.clamp(280, 640).toDouble(), child: child),
      ],
    );
  }
}
