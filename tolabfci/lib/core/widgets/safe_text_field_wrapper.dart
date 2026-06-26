import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper widget that intercepts Arrow Up and Arrow Down keys
/// to prevent Flutter's internal `VerticalCaretMovementRun` assertion crash
/// that happens in centered or RTL (right-aligned) text fields on desktop.
class SafeTextFieldWrapper extends StatelessWidget {
  const SafeTextFieldWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.arrowUp): const DoNothingAndStopPropagationIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowDown): const DoNothingAndStopPropagationIntent(),
      },
      child: child,
    );
  }
}
