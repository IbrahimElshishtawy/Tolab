import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class DeepLinkParser {
  static void navigate(BuildContext context, String deepLink) {
    // Example deep links:
    // lms://task/1
    // lms://subject/2
    // lms://post/3

    final uri = Uri.parse(deepLink);
    if (uri.scheme != 'lms') return;

    final pathSegments = uri.pathSegments;
    if (pathSegments.length < 2) return;

    final type = pathSegments[0];
    final id = pathSegments[1];

    switch (type) {
      case 'task':
        // For now navigate to subjects as a fallback if specific task details not available in route
        context.push('/subjects');
        break;
      case 'subject':
        context.push('/subjects/$id');
        break;
      case 'post':
        context.push('/community');
        break;
    }
  }
}
