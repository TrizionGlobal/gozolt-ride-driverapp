import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../constants/api_constants.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final SecureStorageService _storage;
  final void Function()? onSessionExpired;

  AuthInterceptor({
    required Dio dio,
    required SecureStorageService storage,
    this.onSessionExpired,
  })  : _dio = dio,
        _storage = storage;

  static const _noAuthPaths = [
    ApiConstants.loginDriver,
    ApiConstants.refreshToken,
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_noAuthPaths.contains(options.path)) {
      final token = await _storage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        !_noAuthPaths.contains(err.requestOptions.path)) {
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null) {
          onSessionExpired?.call();
          return handler.reject(err);
        }

        // Use a separate Dio instance to avoid interceptor recursion
        final refreshDio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: {'Content-Type': 'application/json'},
        ));

        final response = await refreshDio.post(
          ApiConstants.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;

        await _storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // Retry the original request with the new token
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _dio.fetch(retryOptions);
        return handler.resolve(retryResponse);
      } on DioException {
        // Refresh failed - force logout
        await _storage.clearTokens();
        onSessionExpired?.call();
        return handler.reject(err);
      }
    }
    handler.next(err);
  }
}
