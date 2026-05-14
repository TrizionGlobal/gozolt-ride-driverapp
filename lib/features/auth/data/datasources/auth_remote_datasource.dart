import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _dio.post(
        ApiConstants.sendOtp,
        data: {'phone': phoneNumber},
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to send OTP');
    }
  }

  Future<LoginResponse> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        data: {
          'phone': phoneNumber,
          'otp': otp,
        },
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid OTP');
      }
      throw ServerException(e.message ?? 'Failed to verify OTP');
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
