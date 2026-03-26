import 'package:flutter/material.dart';

class ScheduleEventModel {
  const ScheduleEventModel({
    required this.id,
    required this.title,
    required this.course,
    required this.instructor,
    required this.location,
    required this.type,
    required this.status,
    required this.start,
    required this.end,
    required this.color,
  });

  final String id;
  final String title;
  final String course;
  final String instructor;
  final String location;
  final String type;
  final String status;
  final DateTime start;
  final DateTime end;
  final Color color;
}
