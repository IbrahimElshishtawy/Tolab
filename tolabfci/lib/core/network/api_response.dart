class ApiResponse<T> {
  const ApiResponse({required this.data, this.message, this.statusCode});

  final T data;
  final String? message;
  final int? statusCode;
}
