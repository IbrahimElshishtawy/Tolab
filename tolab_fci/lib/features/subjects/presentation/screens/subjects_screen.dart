import 'package:flutter/material.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/subject_details_screen.dart';
import 'package:tolab_fci/features/subjects/presentation/widgets/custom_subject_card.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    List<CustomSubjectCard> subjectList = [
      CustomSubjectCard(
        title: 'تحليل البيانات',
        year: 'السنة الرابعة',
        batch: 'دفعة 2022',
        department: 'قسم نظم المعلومات',
        imagePath: 'assets/images/lecture.png',
        firstColor: const Color(0xffD85B5B), // red
        secondColor: const Color(0xffF1A7A7),
      ),
      CustomSubjectCard(
        title: 'هندسة البرمجيات',
        year: 'السنة الثالثة',
        batch: 'دفعة 2023',
        department: 'قسم علوم الحاسب',
        imagePath: 'assets/images/lecture.png',
        firstColor: const Color(0xff4A90E2), // blue
        secondColor: const Color(0xff9BC6F5),
      ),
      CustomSubjectCard(
        title: 'قواعد البيانات',
        year: 'السنة الثانية',
        batch: 'دفعة 2024',
        department: 'قسم نظم المعلومات',
        imagePath: 'assets/images/lecture.png',
        firstColor: const Color(0xff50C878), // green
        secondColor: const Color(0xffA8E6C3),
      ),
      CustomSubjectCard(
        title: 'الذكاء الاصطناعي',
        year: 'السنة الرابعة',
        batch: 'دفعة 2022',
        department: 'قسم علوم الحاسب',
        imagePath: 'assets/images/lecture.png',
        firstColor: const Color(0xff9B59B6), // purple
        secondColor: const Color(0xffD7BDE2),
      ),
      CustomSubjectCard(
        title: 'شبكات الحاسب',
        year: 'السنة الثالثة',
        batch: 'دفعة 2023',
        department: 'قسم تقنية المعلومات',
        imagePath: 'assets/images/lecture.png',
        firstColor: const Color(0xffF39C12), // orange
        secondColor: const Color(0xffFAD7A0),
      ),
      CustomSubjectCard(
        title: 'أمن المعلومات',
        year: 'السنة الرابعة',
        batch: 'دفعة 2022',
        department: 'قسم تقنية المعلومات',
        imagePath: 'assets/images/lecture.png',
        firstColor: const Color(0xff34495E), // dark
        secondColor: const Color(0xff95A5A6),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "المواد الأكاديمية",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: subjectList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubjectDetailsScreen(),
                  ),
                );
              },
              child: subjectList[index]),
          );
        },
      ),
    );
  }
}
