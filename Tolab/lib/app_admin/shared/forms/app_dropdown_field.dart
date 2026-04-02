import 'package:flutter/material.dart';

class AppDropdownItem<T> {
  const AppDropdownItem({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.hint,
    this.onChanged,
  });

  final String label;
  final List<AppDropdownItem<T>> items;
  final T? value;
  final String? hint;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final resolvedItems = <AppDropdownItem<T>>[];
    for (final item in items) {
      final alreadyAdded = resolvedItems.any(
        (resolvedItem) => resolvedItem.value == item.value,
      );
      if (alreadyAdded) continue;
      resolvedItems.add(item);
    }
    final resolvedValue =
        value != null &&
            resolvedItems.where((item) => item.value == value).length == 1
        ? value
        : null;

    return DropdownButtonFormField<T>(
      initialValue: resolvedValue,
      isExpanded: true,
      selectedItemBuilder: (context) => [
        for (final item in resolvedItems)
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 16),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, hintText: hint),
      items: [
        for (final item in resolvedItems)
          DropdownMenuItem<T>(
            value: item.value,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 18),
                  const SizedBox(width: 10),
                ],
                Flexible(child: Text(item.label)),
              ],
            ),
          ),
      ],
    );
  }
}
