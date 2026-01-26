import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tolab_fci/features/home/presentation/widgets/exam_tile.dart';
import 'package:tolab_fci/features/home/presentation/widgets/lecture_card.dart';
import 'package:tolab_fci/features/home/presentation/widgets/title_home.dart';
import 'package:tolab_fci/features/home/presentation/widgets/week_cards.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SvgPicture.asset("assets/svgs/mi_notification.svg"),
        leadingWidth: 50,
        actions: [
          Text(
            "مرحبا احمد",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 10),
          Image.asset("assets/images/pfp.png", height: 50, width: 50),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: TitleHome(title: "التقويم الاسبوعي")),
            SliverToBoxAdapter(child: WeekCards()),
            SliverToBoxAdapter(child: TitleHome(title: "المحاضرات القادمة")),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return LectureCard();
              }, childCount: 2),
            ),
            SliverToBoxAdapter(child: TitleHome(title: "الاختبارات")),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return ExamTile();
              }, childCount: 2),
            ),
            SliverToBoxAdapter(child: TitleHome(title: "المهام")),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return ExamTile();
              }, childCount: 2),
            ),
          ],
        ),
      ),
    );
  }
}
