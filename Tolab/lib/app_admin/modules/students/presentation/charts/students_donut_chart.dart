import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StudentsChartSlice {
  const StudentsChartSlice({
    required this.label,
    required this.value,
    required this.color,
    this.note,
  });

  final String label;
  final double value;
  final Color color;
  final String? note;
}

class StudentsDonutChart extends StatelessWidget {
  const StudentsDonutChart({
    super.key,
    required this.slices,
    this.centerTitle,
    this.centerSubtitle,
  });

  final List<StudentsChartSlice> slices;
  final String? centerTitle;
  final String? centerSubtitle;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 42,
                    sectionsSpace: 3,
                    startDegreeOffset: -90,
                    borderData: FlBorderData(show: false),
                    sections: [
                      for (final slice in slices)
                        PieChartSectionData(
                          color: slice.color,
                          value: slice.value,
                          radius: 18,
                          title: total == 0
                              ? ''
                              : '${((slice.value / total) * 100).round()}%',
                          titleStyle: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(color: Colors.white),
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerTitle ?? total.round().toString(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (centerSubtitle != null)
                      Text(
                        centerSubtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final slice in slices)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: slice.color,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          slice.label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        slice.value.round().toString(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
