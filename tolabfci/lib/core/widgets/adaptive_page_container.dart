import 'package:flutter/material.dart';

import 'responsive_page_container.dart';

class AdaptivePageContainer extends StatelessWidget {
  const AdaptivePageContainer({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ResponsivePageContainer(alignment: alignment, child: child);
  }
}
