String normalizeAuthRole(String? role) {
  final normalized = role?.trim().toLowerCase() ?? '';
  switch (normalized) {
    case 'assistant':
    case 'teaching_assistant':
      return 'ta';
    default:
      return normalized;
  }
}

String landingRouteForRole(String? role) {
  switch (normalizeAuthRole(role)) {
    case 'admin':
      return '/admin/users';
    default:
      return '/home';
  }
}
