class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    required this.message,
    required this.data,
    this.errors,
  });

  final bool success;
  final String message;
  final T data;
  final dynamic errors;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) parser,
  ) {
    return ApiEnvelope<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: parser(json['data']),
      errors: json['errors'],
    );
  }
}
