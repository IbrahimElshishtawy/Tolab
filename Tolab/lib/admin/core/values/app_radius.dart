import 'package:flutter/widgets.dart';

class AppRadius {
  const AppRadius._();

  static const Radius sm = Radius.circular(12);
  static const Radius md = Radius.circular(18);
  static const Radius lg = Radius.circular(24);
  static const BorderRadius card = BorderRadius.all(md);
  static const BorderRadius button = BorderRadius.all(Radius.circular(16));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}
