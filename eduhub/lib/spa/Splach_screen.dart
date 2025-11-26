// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/material.dart';

import 'splash_desktop.dart';
import 'splash_mobile.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  bool get _isDesktop {
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  bool get _isMobile {
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
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
