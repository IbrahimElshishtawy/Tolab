import 'package:flutter/material.dart';
import 'package:tolab_fci/features/schedule/presentation/widgets/custom_schedule_time_card.dart';
import 'package:tolab_fci/features/schedule/presentation/widgets/custom_session_card.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 9.0),
          child: CustomScheduleTimeCard(
            time: '10:30 - 9:00',
            sessions: const [
              CustomSessionCard(
                title: 'هندسة البرمجيات',
                doctor: 'د. أحمد راشد',
                room: 'مدرج 1',
              ),
              CustomSessionCard(
                title: 'الذكاء الاصطناعي',
                doctor: 'د. نور السيد',
                room: 'مدرج 2',
              ),
               CustomSessionCard(
                title: 'الذكاء الاصطناعي',
                doctor: 'د. نور السيد',
                room: 'مدرج 2',
              ),
            ],
          ),
        );
      },
    );
  }
}
