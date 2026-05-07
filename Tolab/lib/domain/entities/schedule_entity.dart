import 'package:equatable/equatable.dart';

class ScheduleEntity extends Equatable {
  final String id;
  final String courseId;
  final String instructorId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String location;
  final String? buildingName;
  final String? roomNumber;
  final int capacity;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const ScheduleEntity({
    required this.id,
    required this.courseId,
    required this.instructorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.buildingName,
    this.roomNumber,
    required this.capacity,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        instructorId,
        dayOfWeek,
        startTime,
        endTime,
        location,
        buildingName,
        roomNumber,
        capacity,
        startDate,
        endDate,
        isActive,
      ];
}
