import 'dart:convert';
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
      final extraDocuments = data['extraDocuments'] as List<Map<String, String>>?;
      data.remove('extraDocuments');
      
      final Map<String, dynamic> formDataMap = {
        ...data,
      };

      if (data['profileImage'] != null) {
        formDataMap['profileImage'] = await MultipartFile.fromFile(data['profileImage'] as String, filename: 'profile.jpg');
      }
      if (data['drivingLicense'] != null) {
        formDataMap['drivingLicense'] = await MultipartFile.fromFile(data['drivingLicense'] as String, filename: 'license.jpg');
      }
      if (data['drivingLicenseBack'] != null) {
        formDataMap['drivingLicenseBack'] = await MultipartFile.fromFile(data['drivingLicenseBack'] as String, filename: 'license_back.jpg');
      }
      if (data['cpcDocument'] != null) {
        formDataMap['cpcDocument'] = await MultipartFile.fromFile(data['cpcDocument'] as String, filename: 'cpc.jpg');
      }
      if (data['idCardDocument'] != null) {
        formDataMap['idCardDocument'] = await MultipartFile.fromFile(data['idCardDocument'] as String, filename: 'idcard.jpg');
      }
      if (data['policeConductDocument'] != null) {
        formDataMap['policeConductDocument'] = await MultipartFile.fromFile(data['policeConductDocument'] as String, filename: 'police_conduct.jpg');
      }
      if (data['proofOfAddressDocument'] != null) {
        formDataMap['proofOfAddressDocument'] = await MultipartFile.fromFile(data['proofOfAddressDocument'] as String, filename: 'proof_of_address.jpg');
      }
      if (data['medicalCertificateDocument'] != null) {
        formDataMap['medicalCertificateDocument'] = await MultipartFile.fromFile(data['medicalCertificateDocument'] as String, filename: 'medical_cert.jpg');
      }
      if (data['workPermitDocument'] != null) {
        formDataMap['workPermitDocument'] = await MultipartFile.fromFile(data['workPermitDocument'] as String, filename: 'work_permit.jpg');
      }
      if (data['insuranceDocument'] != null) {
        formDataMap['insuranceDocument'] = await MultipartFile.fromFile(data['insuranceDocument'] as String, filename: 'insurance.jpg');
      }

      if (extraDocuments != null && extraDocuments.isNotEmpty) {
        final Map<String, String> extraNames = {};
        for (int i = 0; i < extraDocuments.length; i++) {
          final doc = extraDocuments[i];
          if (doc['path'] != null && doc['path']!.isNotEmpty) {
            final fieldName = 'extraDocument_$i';
            formDataMap[fieldName] = await MultipartFile.fromFile(doc['path']!, filename: 'extra_$i.jpg');
            extraNames[fieldName] = doc['name'] ?? 'Extra Document';
          }
        }
        formDataMap['extraDocumentNames'] = jsonEncode(extraNames);
      }

      final formData = FormData.fromMap(formDataMap);

      await _dio.post(
        ApiConstants.registerDriver,
        data: formData,
        options: Options(
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
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

  Future<void> forgotPassword(String driverId) async {
    try {
      await _dio.post(
        ApiConstants.driverForgotPassword,
        data: {'driverId': driverId},
      );
    } on DioException catch (e) {
      throw ServerException(_parseError(e, 'Failed to send OTP. Please check your Driver ID.'));
    }
  }

  Future<void> resetPassword(String driverId, String newPassword) async {
    try {
      await _dio.post(
        ApiConstants.driverResetPassword,
        data: {
          'driverId': driverId,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ServerException(_parseError(e, 'Failed to reset password.'));
    }
  }

  String _parseError(DioException e, String defaultMsg) {
    // Handle network or connection related errors with a friendly message
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout || 
        e.type == DioExceptionType.sendTimeout || 
        e.type == DioExceptionType.connectionError) {
      return 'Connection lost. Please check your internet connection and try again.';
    }

    // Handle unknown types wrapping SocketException (like Failed host lookup)
    if (e.type == DioExceptionType.unknown && 
        (e.message?.contains('Failed host lookup') == true || 
         e.message?.contains('SocketException') == true || 
         e.message?.contains('Connection refused') == true)) {
      return 'Connection lost. Please check your internet connection and try again.';
    }

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
    return defaultMsg;
  }
}
