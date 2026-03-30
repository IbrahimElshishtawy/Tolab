import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../models/settings_models.dart';

class SettingsGlassCard extends StatelessWidget {
  const SettingsGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AnimatedContainer(
          duration: AppMotion.medium,
          curve: AppMotion.emphasized,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.surfaceDark : Colors.white).withValues(
              alpha: isDark ? 0.74 : 0.72,
            ),
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            border: Border.all(
              color: (isDark ? AppColors.strokeDark : AppColors.strokeLight)
                  .withValues(alpha: 0.72),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.10),
                blurRadius: 26,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SettingsSectionButton extends StatelessWidget {
  const SettingsSectionButton({
    super.key,
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final SettingsSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.emphasized,
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(
          color: selected ? color.withValues(alpha: 0.24) : Colors.transparent,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(section.icon, color: selected ? color : null),
        title: Text(
          section.label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: selected ? color : null,
          ),
        ),
        subtitle: Text(
          section.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class SettingsStatChip extends StatelessWidget {
  const SettingsStatChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class SettingsBlockHeader extends StatelessWidget {
  const SettingsBlockHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.emphasized,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: color.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class SettingsTextInput extends StatefulWidget {
  const SettingsTextInput({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
  });

  final String value;
  final String label;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  @override
  State<SettingsTextInput> createState() => _SettingsTextInputState();
}

class _SettingsTextInputState extends State<SettingsTextInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant SettingsTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == _controller.text || _focusNode.hasFocus) return;
    _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
      ),
    );
  }
}

class SettingsNumberInput extends StatelessWidget {
  const SettingsNumberInput({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.hintText,
  });

  final int value;
  final String label;
  final ValueChanged<int> onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return SettingsTextInput(
      value: '$value',
      label: label,
      hintText: hintText,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) onChanged(parsed);
      },
    );
  }
}

class SettingsDropdownField<T> extends StatelessWidget {
  const SettingsDropdownField({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final String label;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item,
            child: Text(labelBuilder(item)),
          ),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
      decoration: InputDecoration(labelText: label),
    );
  }
}

class SettingsColorField extends StatelessWidget {
  const SettingsColorField({
    super.key,
    required this.label,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.inputRadius),
      onTap: () async {
        final picked = await showDialog<Color>(
          context: context,
          builder: (context) => _ColorPickerDialog(initialColor: color),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(_hex(color)),
            const Spacer(),
            const Icon(Icons.color_lens_outlined),
          ],
        ),
      ),
    );
  }

  String _hex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}

class SettingsEmptyStateCard extends StatelessWidget {
  const SettingsEmptyStateCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SettingsGlassCard(
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 32),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class SettingsDateChip extends StatelessWidget {
  const SettingsDateChip({
    super.key,
    required this.date,
    required this.onTap,
  });

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.event_rounded, size: 18),
      label: Text(DateFormat('MMM d, yyyy').format(date)),
      onPressed: onTap,
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.initialColor});

  final Color initialColor;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  static const List<Color> _palette = [
    Color(0xFF2563EB),
    Color(0xFF0EA5E9),
    Color(0xFF16A34A),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFE11D48),
    Color(0xFF0F766E),
    Color(0xFF111827),
  ];

  late Color _selected;
  late final TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor;
    _hexController = TextEditingController(text: _hex(widget.initialColor));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose accent color'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final color in _palette)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selected = color;
                        _hexController.text = _hex(color);
                      });
                    },
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selected.value == color.value
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.26),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _hexController,
              decoration: const InputDecoration(
                labelText: 'Hex',
                hintText: '#2563EB',
              ),
              onChanged: (value) {
                final parsed = _parseHex(value);
                if (parsed != null) {
                  setState(() => _selected = parsed);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Color? _parseHex(String value) {
    final normalized = value.trim().replaceFirst('#', '');
    if (normalized.isEmpty) return null;
    final full = normalized.length == 6 ? 'FF$normalized' : normalized;
    final parsed = int.tryParse(full, radix: 16);
    if (parsed == null) return null;
    return Color(parsed);
  }

  String _hex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}
