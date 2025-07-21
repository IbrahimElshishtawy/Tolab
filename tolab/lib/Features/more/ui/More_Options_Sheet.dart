// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'package:tolab/Features/more/items_option/more_side_items.dart';

class MoreSidePanel extends StatelessWidget {
  const MoreSidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        /// 🟡 خلفية شفافة تغلق عند الضغط
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height,
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey.shade900.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black45 : Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(-4, 0),
                  ),
                ],
              ),
              child: const MoreSideItems(),
            ),
          ),
        ),
      ],
    );
  }
}
