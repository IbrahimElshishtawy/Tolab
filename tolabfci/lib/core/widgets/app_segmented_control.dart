import 'package:flutter/cupertino.dart';

class AppSegmentedControl<T extends Object> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.groupValue,
    required this.children,
    required this.onValueChanged,
  });

  final T groupValue;
  final Map<T, Widget> children;
  final ValueChanged<T> onValueChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<T>(
      groupValue: groupValue,
      children: children,
      onValueChanged: (value) {
        if (value != null) {
          onValueChanged(value);
        }
      },
    );
  }
}
