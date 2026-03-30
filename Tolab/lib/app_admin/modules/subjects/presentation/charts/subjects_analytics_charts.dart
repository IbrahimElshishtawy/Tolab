import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../design/subjects_management_tokens.dart';

class SubjectsActivityLineChart extends StatelessWidget {
  const SubjectsActivityLineChart({
    super.key,
    required this.values,
    required this.color,
  });

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: LineChart(
        LineChartData(
          minY: 0,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: color,
              barWidth: 2.5,
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i * 1.0, values[i]),
              ],
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.18),
                    color.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectsDepartmentDonutChart extends StatelessWidget {
  const SubjectsDepartmentDonutChart({super.key, required this.items});

  final List<DepartmentDistributionItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 34,
              borderData: FlBorderData(show: false),
              sections: [
                for (final item in items)
                  PieChartSectionData(
                    value: item.value.toDouble(),
                    radius: 18,
                    color: item.color,
                    title: '',
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final item in items) ...[
                _LegendRow(item: item),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SubjectsYearBarsChart extends StatelessWidget {
  const SubjectsYearBarsChart({super.key, required this.items});

  final List<YearBarItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (items
                          .map((item) => item.value)
                          .fold<int>(0, (a, b) => a > b ? a : b) +
                      2)
                  .toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: SubjectsManagementPalette.border(context),
              strokeWidth: 0.7,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: const BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
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
                  if (index < 0 || index >= items.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      items[index].label,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < items.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: items[i].value.toDouble(),
                    width: 18,
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        items[i].color.withValues(alpha: 0.90),
                        items[i].color.withValues(alpha: 0.55),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class DepartmentDistributionItem {
  const DepartmentDistributionItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

class YearBarItem {
  const YearBarItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.item});

  final DepartmentDistributionItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(item.label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text('${item.value}', style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
