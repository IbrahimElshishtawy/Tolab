import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'students_donut_chart.dart';

class StudentsBarChart extends StatelessWidget {
  const StudentsBarChart({super.key, required this.slices, this.maxY});

  final List<StudentsChartSlice> slices;
  final double? maxY;

  @override
  Widget build(BuildContext context) {
    final topY =
        maxY ??
        slices
                .map((slice) => slice.value)
                .fold<double>(
                  0,
                  (highest, value) => value > highest ? value : highest,
                ) +
            1;

    return BarChart(
      BarChartData(
        maxY: topY,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: topY <= 6 ? 1 : topY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= slices.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    slices[index].label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var index = 0; index < slices.length; index++)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: slices[index].value,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  color: slices[index].color,
                ),
              ],
            ),
        ],
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final slice = slices[group.x.toInt()];
              return BarTooltipItem(
                '${slice.label}\n${slice.value.round()}',
                Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
