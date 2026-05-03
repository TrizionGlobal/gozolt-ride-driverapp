import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.loginDriver,
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 400:
        case 401:
          throw const UnauthorizedException('Invalid driver ID or password');
        default:
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            throw const ConnectionTimeoutException();
          }
          if (e.type == DioExceptionType.connectionError) {
            throw const NetworkException();
          }
          throw ServerException(e.message ?? 'Server error');
      }
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException {
      // Logout failure is non-critical; we clear local tokens regardless
    }
  }
}
