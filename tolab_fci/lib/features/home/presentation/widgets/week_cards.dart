import 'package:flutter/material.dart';

class WeekCards extends StatefulWidget {
  const WeekCards({super.key});

  @override
  State<WeekCards> createState() => _WeekSelectorState();
}

class _WeekSelectorState extends State<WeekCards> {
  int selectedIndex = 0;
  final week = generateWeek();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85,
      child: ListView.separated(
        reverse: true,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: week.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = week[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() => selectedIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getArabicDayName(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}



List<DateTime> generateWeek() {
  final today = DateTime.now();
  return List.generate(
    7,
    (index) => today.add(Duration(days: index)),
  );
}


String getArabicDayName(DateTime date) {
  const days = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];
  return days[date.weekday % 7];
}
