class TimetableItem {
  const TimetableItem({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.title,
    required this.typeLabel,
    required this.locationLabel,
    required this.hostName,
    required this.startsAt,
    required this.endsAt,
    required this.routeName,
    required this.pathParameters,
  });

  final String id;
  final String subjectId;
  final String subjectName;
  final String title;
  final String typeLabel;
  final String locationLabel;
  final String hostName;
  final DateTime startsAt;
  final DateTime endsAt;
  final String routeName;
  final Map<String, String> pathParameters;
}
