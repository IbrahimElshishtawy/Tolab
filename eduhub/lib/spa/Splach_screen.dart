import 'package:eduhub/spa/Splash_desktop.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'splash_mobile.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  bool get _isDesktop {
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (e) {
      return false; // في حالة Web
    }
  }

  bool get _isMobile {
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDesktop) {
      return const SplashDesktop();
    } else if (_isMobile) {
      return const SplashMobile();
    } else {
      return const SplashMobile();
    }
  }
}
