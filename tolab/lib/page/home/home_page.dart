// ignore_for_file: deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tolab/page/more/ui/More_Options_Sheet.dart';
import 'package:tolab/page/posts/pages/posts_page.dart';

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
    const SizedBox(),
  ];

  void _onPageChanged(int index) {
    if (index == 4) {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      _openMorePanel();
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _onTap(int index) {
    if (index == 4) {
      _openMorePanel();
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openMorePanel() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) =>
          const Align(alignment: Alignment.centerRight, child: MoreSidePanel()),
      transitionBuilder: (_, anim, __, child) {
        final curved = Curves.easeInOut.transform(anim.value) - 1.0;
        return Transform.translate(
          offset: Offset(300 * curved, 0),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color.fromRGBO(152, 172, 201, 1);
    final icons = [
      FontAwesomeIcons.bookOpen,
      FontAwesomeIcons.comments,
      FontAwesomeIcons.house,
      FontAwesomeIcons.calendar,
      FontAwesomeIcons.ellipsisV,
    ];

    double itemWidth = (MediaQuery.of(context).size.width - 40) / icons.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SizedBox(
            height: 60,
            child: Stack(
              children: [
                // خلفية الشريط
                Container(
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
                ),

                // مؤشر أسفل الأيقونة المحددة
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _currentIndex * itemWidth,
                  bottom: 0,
                  child: Container(
                    width: itemWidth,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // الأيقونات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(icons.length, (index) {
                    final isSelected = _currentIndex == index;

                    return GestureDetector(
                      onTap: () => _onTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        width: itemWidth,
                        height: 60,
                        child: Center(
                          child: AnimatedScale(
                            scale: isSelected ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: FaIcon(
                              icons[index],
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.6),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
