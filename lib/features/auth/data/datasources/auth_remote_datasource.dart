import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);
  
  Future<void> register(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap({
        ...data,
        if (data['profileImage'] != null)
          'profileImage': await MultipartFile.fromFile(data['profileImage'] as String, filename: 'profile.jpg'),
        if (data['drivingLicense'] != null)
          'drivingLicense': await MultipartFile.fromFile(data['drivingLicense'] as String, filename: 'license.jpg'),
        if (data['cpcDocument'] != null)
          'cpcDocument': await MultipartFile.fromFile(data['cpcDocument'] as String, filename: 'cpc.jpg'),
        if (data['insuranceDocument'] != null)
          'insuranceDocument': await MultipartFile.fromFile(data['insuranceDocument'] as String, filename: 'insurance.jpg'),
      });

      await _dio.post(
        ApiConstants.registerDriver,
        data: formData,
      );
    } on DioException catch (e) {
      throw ServerException(_parseError(e, 'Registration failed'));
    }
  }

  Future<void> sendRegisterOtp(String phoneNumber) async {
    try {
      await _dio.post(
        ApiConstants.sendRegisterOtp,
        data: {'phone': phoneNumber},
      );
    } on DioException catch (e) {
      throw ServerException(_parseError(e, 'Failed to send OTP'));
    }
  }

  Future<void> verifyRegisterOtp(String phoneNumber, String otp) async {
    try {
      await _dio.post(
        ApiConstants.verifyRegisterOtp,
        data: {
          'phone': phoneNumber,
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid OTP');
      }
      throw ServerException(_parseError(e, 'Failed to verify OTP'));
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _dio.post(
        ApiConstants.sendOtp,
        data: {'phone': phoneNumber},
      );
    } on DioException catch (e) {
      throw ServerException(_parseError(e, 'Failed to send OTP'));
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
      throw ServerException(_parseError(e, 'Failed to verify OTP'));
    }
  }

  Future<LoginResponse> loginWithPassword(String driverId, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.loginDriver,
        data: {
          'driverId': driverId,
          'password': password,
        },
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid credentials');
      }
      throw ServerException(_parseError(e, 'Login failed'));
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException {
      // Logout failure is non-critical; we clear local tokens regardless
    }
  }

  String _parseError(DioException e, String defaultMsg) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        final msg = data['message'];
        if (msg is List) {
          return msg.join(', ');
        } else if (msg is String) {
          return msg;
        }
      }
    }
    return e.message ?? defaultMsg;
  }
}
