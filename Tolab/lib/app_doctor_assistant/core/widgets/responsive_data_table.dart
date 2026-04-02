import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
import '../responsive/app_breakpoints.dart';
import 'app_card.dart';

class ResponsiveDataTable extends StatelessWidget {
  const ResponsiveDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.mobileBuilder,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final List<Widget> Function() mobileBuilder;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppBreakpoints.tablet) {
      return Column(
        children: mobileBuilder()
            .map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: child,
              ),
            )
            .toList(),
      );
    }

    return AppCard(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns,
          rows: rows,
          horizontalMargin: AppSpacing.lg,
          columnSpacing: AppSpacing.xl,
        ),
      ),
    );
  }
}
