class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.meta,
  });

  final bool success;
  final String message;
  final T? data;
  final dynamic errors;
  final Map<String, dynamic>? meta;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic raw)? parser,
  }) {
    final rawData = json['data'];
    return ApiEnvelope<T>(
      success: json['success'] == true,
      message: (json['message'] as String?) ?? '',
      data: parser != null ? parser(rawData) : rawData as T?,
      errors: json['errors'],
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : null,
    );
  }
}
