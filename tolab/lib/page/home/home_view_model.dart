import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  int _currentIndex = 2;
  int get currentIndex => _currentIndex;

  final PageController pageController = PageController(initialPage: 2);

  void onPageChanged(int index, VoidCallback openMorePanel) {
    if (index == 4) {
      pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      openMorePanel();
    } else {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void onTap(int index, VoidCallback openMorePanel) {
    if (index == 4) {
      openMorePanel();
    } else {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
