class ScheduleEventModel {
  const ScheduleEventModel({
    required this.id,
    required this.title,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.location,
    this.type = 'lecture',
  });

  final String id;
  final String title;
  final String day;
  final String startTime;
  final String endTime;
  final String? location;
  final String type;

  factory ScheduleEventModel.fromJson(Map<String, dynamic> json) {
    return ScheduleEventModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['course_name'] ?? 'Class') as String,
      day: (json['day'] ?? json['weekday'] ?? 'Day') as String,
      startTime: (json['start_time'] ?? '--:--') as String,
      endTime: (json['end_time'] ?? '--:--') as String,
      location: json['location'] as String?,
      type: (json['type'] ?? 'lecture') as String,
    );
  }
}
