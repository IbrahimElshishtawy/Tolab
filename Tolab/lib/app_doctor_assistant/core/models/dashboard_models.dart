class DashboardMetric {
  const DashboardMetric({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  factory DashboardMetric.fromJson(Map<String, dynamic> json) {
    return DashboardMetric(
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '0',
      caption: json['caption']?.toString() ?? '',
    );
  }
}

class DashboardSnapshot {
  const DashboardSnapshot({
    this.metrics = const <DashboardMetric>[],
    this.upcoming = const <Map<String, dynamic>>[],
    this.quickActions = const <String>[],
  });

  final List<DashboardMetric> metrics;
  final List<Map<String, dynamic>> upcoming;
  final List<String> quickActions;

  factory DashboardSnapshot.fromJson(Map<String, dynamic> json) {
    return DashboardSnapshot(
      metrics: (json['metrics'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DashboardMetric.fromJson)
          .toList(),
      upcoming: (json['upcoming'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(),
      quickActions: (json['quick_actions'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}
