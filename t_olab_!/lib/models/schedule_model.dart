class ScheduleModel {
  final String id;
  final String title;
  final String teacherId;
  final String day; // e.g., "Monday"
  final String time; // e.g., "10:00 AM - 12:00 PM"
  final bool isEvenWeek;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.teacherId,
    required this.day,
    required this.time,
    required this.isEvenWeek,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
    id: json['id'],
    title: json['title'],
    teacherId: json['teacher_id'],
    day: json['day'],
    time: json['time'],
    isEvenWeek: json['is_even_week'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'teacher_id': teacherId,
    'day': day,
    'time': time,
    'is_even_week': isEvenWeek,
  };
}
