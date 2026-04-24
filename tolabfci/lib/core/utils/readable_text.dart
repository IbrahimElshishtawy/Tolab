bool looksCorruptedText(String? value) {
  if (value == null || value.isEmpty) {
    return false;
  }

  final markerCount = RegExp(
    r'[ØÙÃÂ�]|â(?:€¢|€“|€™|€Œ|€ڈ)',
  ).allMatches(value).length;
  return markerCount >= 2;
}

String readableText(String? value, String fallback) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty || looksCorruptedText(trimmed)) {
    return fallback;
  }
  return trimmed;
}
