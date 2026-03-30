import 'package:flutter/material.dart';

class KpiMetric {
  const KpiMetric({
    required this.label,
    required this.value,
    required this.delta,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String delta;
  final Color color;
  final IconData icon;
}

class TrendPoint {
  const TrendPoint(this.label, this.value);

  final String label;
  final double value;
}

class DistributionSlice {
  const DistributionSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
  });

  final String title;
  final String subtitle;
  final String timestamp;
  final String type;
}

class DashboardBundle {
  const DashboardBundle({
    required this.metrics,
    required this.trends,
    required this.distribution,
    required this.activities,
    required this.alerts,
  });

  final List<KpiMetric> metrics;
  final List<TrendPoint> trends;
  final List<DistributionSlice> distribution;
  final List<ActivityItem> activities;
  final List<String> alerts;
}
