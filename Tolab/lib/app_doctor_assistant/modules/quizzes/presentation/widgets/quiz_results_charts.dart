import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../../../../core/design/app_spacing.dart';
import '../models/quizzes_workspace_models.dart';

class QuizResultsCharts extends StatelessWidget {
  const QuizResultsCharts({super.key, required this.quiz});

  final QuizWorkspaceItem quiz;

  @override
  Widget build(BuildContext context) {
    final gradeBuckets = buildQuizGradeBuckets(quiz);
    final submissionTrend = buildQuizSubmissionTrend(quiz);
    final completed = quiz.completedStudents.toDouble();
    final incomplete = max(
      0,
      quiz.totalStudents - quiz.completedStudents,
    ).toDouble();

    return Column(
      children: [
        _ChartCard(
          title: 'Grade Distribution',
          subtitle: 'A score spread across the current completed submissions.',
          child: SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: max<double>(
                  4,
                  gradeBuckets.fold<double>(
                        0,
                        (maxValue, bucket) =>
                            max(maxValue, bucket.count.toDouble()),
                      ) +
                      1,
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= gradeBuckets.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(gradeBuckets[index].label),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List<BarChartGroupData>.generate(
                  gradeBuckets.length,
                  (index) {
                    final bucket = gradeBuckets[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: bucket.count.toDouble(),
                          color: bucket.color,
                          borderRadius: BorderRadius.circular(8),
                          width: 24,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ChartCard(
                title: 'Completion Split',
                subtitle: 'Completed versus incomplete participation.',
                child: SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 56,
                      sectionsSpace: 4,
                      sections: [
                        PieChartSectionData(
                          value: completed,
                          color: const Color(0xFF2563EB),
                          radius: 64,
                          title: completed == 0
                              ? ''
                              : completed.toInt().toString(),
                        ),
                        PieChartSectionData(
                          value: incomplete,
                          color: const Color(0xFFF59E0B),
                          radius: 64,
                          title: incomplete == 0
                              ? ''
                              : incomplete.toInt().toString(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _ChartCard(
                title: 'Submission Trend',
                subtitle: 'A lightweight timeline of completed submissions.',
                child: SizedBox(
                  height: 220,
                  child: submissionTrend.isEmpty
                      ? const Center(child: Text('No submission points yet'))
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            minY: 0,
                            maxY: max<double>(
                              3,
                              submissionTrend.last.value + 1,
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 ||
                                        index >= submissionTrend.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        submissionTrend[index].label,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                color: const Color(0xFF14B8A6),
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                spots: List<FlSpot>.generate(
                                  submissionTrend.length,
                                  (index) => FlSpot(
                                    index.toDouble(),
                                    submissionTrend[index].value,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: title,
      subtitle: subtitle,
      child: Container(
        decoration: BoxDecoration(
          color: tokens.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: tokens.border),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}
