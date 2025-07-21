// ignore_for_file: sort_child_properties_last, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tolab/Features/more/ui/More_Options_Sheet.dart';
import 'package:tolab/Features/posts/pages/posts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('📚 المواد')),
    const Center(child: Text('💬 الشاتات')),
    const PostsPage(),
    const Center(child: Text('📅 الجدول الدراسي')),
    const SizedBox(), // لـ "المزيد"
  ];
  void _onPageChanged(int index) {
    if (index == 4) {
      // رجّع على الصفحة السابقة حتى ما تظهر صفحة فاضية
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );

      // افتح الشريط الجانبي
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation1, animation2) {
          return const Align(
            alignment: Alignment.centerRight,
            child: MoreSidePanel(),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curvedValue = Curves.easeInOut.transform(animation.value) - 1.0;
          return Transform.translate(
            offset: Offset(300 * curvedValue, 0),
            child: child,
          );
        },
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _onTap(int index) {
    if (index == 4) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation1, animation2) {
          return const Align(
            alignment: Alignment.centerRight,
            child: MoreSidePanel(),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curvedValue = Curves.easeInOut.transform(animation.value) - 1.0;
          return Transform.translate(
            offset: Offset(300 * curvedValue, 0),
            child: child,
          );
        },
      );
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = Colors.white;
    final unselectedColor = Colors.white.withOpacity(0.6);
    final backgroundColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color.fromRGBO(152, 172, 201, 1);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(), // سحب ناعم
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                onTap: _onTap,
                selectedItemColor: selectedColor,
                unselectedItemColor: unselectedColor,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                iconSize: 22,
                items: const [
                  BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.bookOpen), // المواد
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.comments), // الشاتات
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.house), // البوستات
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.calendar), // الجدول الدراسي
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.ellipsisV), // المزيد
                    label: '',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
