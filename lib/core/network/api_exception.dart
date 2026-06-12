sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Unauthorized'])
      : super(statusCode: 401);
}

class BadRequestException extends ApiException {
  const BadRequestException([super.message = 'Bad request'])
      : super(statusCode: 400);
}

class ServerException extends ApiException {
  const ServerException([super.message = 'Server error'])
      : super(statusCode: 500);
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'Connection lost. Please check your internet connection and try again.']);
}

class ConnectionTimeoutException extends ApiException {
  const ConnectionTimeoutException([super.message = 'Connection lost. Please check your internet connection and try again.']);
}
