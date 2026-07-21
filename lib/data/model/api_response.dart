class ApiResponse<T> {
  final bool    success;
  final T?      data;
  final String  message;
  final int     statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message = '',
    this.statusCode = 0,
  });

  factory ApiResponse.ok(T data, {String message = ''}) =>
      ApiResponse(success: true, data: data, message: message, statusCode: 200);

  factory ApiResponse.fail(String message, {int code = 0}) =>
      ApiResponse(success: false, message: message, statusCode: code);

  factory ApiResponse.fromMap(
    Map<String, dynamic> result, {
    T Function(dynamic)? parser,
  }) {
    if (result['status'] != true) {
      return ApiResponse.fail(
        result['message']?.toString() ?? 'حدث خطأ غير متوقع',
        code: result['code'] as int? ?? 0,
      );
    }
    final raw = result['data'];
    return ApiResponse.ok(
      parser != null ? parser(raw) : raw as T,
      message: result['message']?.toString() ?? '',
    );
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound     => statusCode == 404;
  bool get isServerError  => statusCode >= 500;

  @override
  String toString() =>
      'ApiResponse(success: $success, code: $statusCode, msg: "$message")';
}
