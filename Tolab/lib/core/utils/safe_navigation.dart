import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Utility class for safe GoRouter navigation
///
/// This class provides helper methods to safely navigate using GoRouter
/// while preventing common errors like:
/// - Popping the last page off the stack
/// - _debugLocked assertion errors
/// - Navigation after widget disposal
class SafeNavigation {
  /// Safely pop the current page
  ///
  /// If there's a page to pop, pops it. Otherwise, navigates to the home route.
  /// Uses [addPostFrameCallback] to prevent frame locking errors.
  ///
  /// Example:
  /// ```dart
  /// SafeNavigation.pop(context);
  /// ```
  static void pop(BuildContext context) {
    _navigateAfterFrame(context, () {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    });
  }

  /// Safely pop with a fallback route
  ///
  /// If there's a page to pop, pops it. Otherwise, navigates to [fallbackRoute].
  ///
  /// Example:
  /// ```dart
  /// SafeNavigation.popOrGo(context, '/dashboard');
  /// ```
  static void popOrGo(BuildContext context, String fallbackRoute) {
    _navigateAfterFrame(context, () {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(fallbackRoute);
      }
    });
  }

  /// Safely navigate to a route
  ///
  /// Uses [addPostFrameCallback] to prevent frame locking errors.
  ///
  /// Example:
  /// ```dart
  /// SafeNavigation.go(context, '/courses');
  /// ```
  static void go(BuildContext context, String route) {
    _navigateAfterFrame(context, () {
      context.go(route);
    });
  }

  /// Safely push a new route
  ///
  /// Uses [addPostFrameCallback] to prevent frame locking errors.
  ///
  /// Example:
  /// ```dart
  /// SafeNavigation.push(context, '/add-lecture');
  /// ```
  static void push(BuildContext context, String route) {
    _navigateAfterFrame(context, () {
      context.push(route);
    });
  }

  /// Safely push a named route with parameters
  ///
  /// Example:
  /// ```dart
  /// SafeNavigation.pushNamed(
  ///   context,
  ///   'edit-lecture',
  ///   pathParameters: {'id': '123'},
  /// );
  /// ```
  static void pushNamed(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
  }) {
    _navigateAfterFrame(context, () {
      context.pushNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      );
    });
  }

  /// Check if the current page can be popped
  ///
  /// Example:
  /// ```dart
  /// if (SafeNavigation.canPop(context)) {
  ///   SafeNavigation.pop(context);
  /// }
  /// ```
  static bool canPop(BuildContext context) {
    return context.canPop();
  }

  /// Execute navigation after the current frame completes
  ///
  /// This prevents _debugLocked assertion errors by ensuring
  /// navigation happens after the frame is fully rendered.
  ///
  /// Private helper method used by other navigation methods.
  static void _navigateAfterFrame(
    BuildContext context,
    VoidCallback navigation,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        navigation();
      } catch (e) {
        debugPrint('Navigation error: $e');
        // Fallback to home on error
        try {
          context.go('/home');
        } catch (fallbackError) {
          debugPrint('Fallback navigation failed: $fallbackError');
        }
      }
    });
  }
}

/// Extension on BuildContext for convenient safe navigation
extension SafeNavigationExtension on BuildContext {
  /// Safely pop the current page
  ///
  /// Example:
  /// ```dart
  /// context.safePop();
  /// ```
  void safePop() => SafeNavigation.pop(this);

  /// Safely pop with a fallback route
  ///
  /// Example:
  /// ```dart
  /// context.safePopOrGo('/dashboard');
  /// ```
  void safePopOrGo(String fallbackRoute) =>
      SafeNavigation.popOrGo(this, fallbackRoute);

  /// Safely navigate to a route
  ///
  /// Example:
  /// ```dart
  /// context.safeGo('/courses');
  /// ```
  void safeGo(String route) => SafeNavigation.go(this, route);

  /// Safely push a new route
  ///
  /// Example:
  /// ```dart
  /// context.safePush('/add-lecture');
  /// ```
  void safePush(String route) => SafeNavigation.push(this, route);

  /// Check if the current page can be popped
  ///
  /// Example:
  /// ```dart
  /// if (context.canSafePop()) {
  ///   context.safePop();
  /// }
  /// ```
  bool canSafePop() => SafeNavigation.canPop(this);
}
