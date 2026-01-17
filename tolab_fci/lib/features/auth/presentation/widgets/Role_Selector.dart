// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      initialValue: selectedRole,
      isExpanded: true,
      dropdownColor: theme.colorScheme.surface,
      focusColor: theme.colorScheme.primary.withOpacity(0.08),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: theme.iconTheme.color,
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'نوع الحساب',
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        filled: true,
        fillColor: isDark
            ? theme.colorScheme.surfaceVariant.withOpacity(0.4)
            : theme.colorScheme.primary.withOpacity(0.04),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'student', child: Text('طالب')),
        DropdownMenuItem(value: 'doctor', child: Text('دكتور')),
        DropdownMenuItem(value: 'ta', child: Text('معيد')),
        DropdownMenuItem(value: 'it', child: Text('IT')),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
