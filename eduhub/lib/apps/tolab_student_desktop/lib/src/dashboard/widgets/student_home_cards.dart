import 'package:flutter/material.dart';

class ScheduleItem {
  final String title;
  final String subtitle;
  final DateTime dateTime;

  const ScheduleItem({
    required this.title,
    required this.subtitle,
    required this.dateTime,
  });
}

// عينات بيانات – لاحقاً تجي من backend
List<ScheduleItem> sampleLectures() {
  final now = DateTime.now();
  return [
    ScheduleItem(
      title: 'Data Structures',
      subtitle: 'Dr. Ahmed Hassan',
      dateTime: DateTime(now.year, now.month, now.day, 10, 0),
    ),
    ScheduleItem(
      title: 'Operating Systems',
      subtitle: 'Dr. Sara Ali',
      dateTime: now.add(const Duration(days: 1)).copyWith(hour: 12, minute: 0),
    ),
  ];
}

List<ScheduleItem> sampleQuizzes() {
  final now = DateTime.now();
  return [
    ScheduleItem(
      title: 'Database Quiz 1',
      subtitle: 'Assistant: Mohamed',
      dateTime: now.add(const Duration(days: 2)).copyWith(hour: 15),
    ),
    ScheduleItem(
      title: 'Math Quiz 2',
      subtitle: 'Assistant: Ali',
      dateTime: now.add(const Duration(days: 4)).copyWith(hour: 9),
    ),
  ];
}

// ============ Widgets ============

class AccountDetailsCard extends StatelessWidget {
  final String studentName;
  final String department;
  final String academicYear;

  const AccountDetailsCard({
    super.key,
    required this.studentName,
    required this.department,
    required this.academicYear,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Account details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(label: 'Student name', value: studentName),
          _DetailRow(label: 'Department', value: department),
          _DetailRow(label: 'Academic year', value: academicYear),
        ],
      ),
    );
  }
}

class UpcomingLecturesCard extends StatelessWidget {
  final DateTime selectedDay;

  const UpcomingLecturesCard({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final lectures = sampleLectures()
        .where(
          (l) =>
              l.dateTime.year == selectedDay.year &&
              l.dateTime.month == selectedDay.month &&
              l.dateTime.day == selectedDay.day,
        )
        .toList();

    return _CardShell(
      title: 'Upcoming online lectures',
      child: lectures.isEmpty
          ? const Text(
              'No lectures for this day',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            )
          : Column(
              children: [
                for (final l in lectures) ...[
                  _ListItemRow(
                    title: l.title,
                    subtitle: l.subtitle,
                    trailing:
                        '${l.dateTime.hour.toString().padLeft(2, '0')}:${l.dateTime.minute.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class UpcomingQuizzesCard extends StatelessWidget {
  final DateTime selectedDay;

  const UpcomingQuizzesCard({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final quizzes = sampleQuizzes()
        .where(
          (q) =>
              q.dateTime.year == selectedDay.year &&
              q.dateTime.month == selectedDay.month &&
              q.dateTime.day == selectedDay.day,
        )
        .toList();

    return _CardShell(
      title: 'Upcoming online quizzes',
      child: quizzes.isEmpty
          ? const Text(
              'No quizzes for this day',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            )
          : Column(
              children: [
                for (final q in quizzes) ...[
                  _ListItemRow(
                    title: q.title,
                    subtitle: q.subtitle,
                    trailing:
                        '${q.dateTime.hour.toString().padLeft(2, '0')}:${q.dateTime.minute.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

class DayCalendarCard extends StatelessWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  const DayCalendarCard({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final startOfWeek = selectedDay.subtract(
      Duration(days: selectedDay.weekday - 1),
    );
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return _CardShell(
      title: 'Day calendar',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < days.length; i++)
            _CalendarDayItem(
              label: dayNames[i],
              date: days[i],
              isSelected: _isSameDate(days[i], selectedDay),
              onTap: () => onDaySelected(days[i]),
            ),
        ],
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// ============ عناصر داخلية ============

class _CardShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Colors.black54,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListItemRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;

  const _ListItemRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            trailing,
            style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CalendarDayItem extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _CalendarDayItem({
    required this.label,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayNumber = date.day.toString();

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              dayNumber,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
