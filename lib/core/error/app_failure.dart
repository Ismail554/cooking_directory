/// Domain-level failure representation.
class AppFailure {
  const AppFailure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AppFailure(message: $message, statusCode: $statusCode)';
}
