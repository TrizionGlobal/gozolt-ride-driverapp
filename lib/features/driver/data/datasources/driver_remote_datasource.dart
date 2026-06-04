import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../models/driver_profile.dart';
import '../models/earnings_summary.dart';
import '../models/daily_earnings.dart';
import '../models/driver_earnings_balance.dart';
import '../models/driver_ratings_response.dart';

class DriverRemoteDataSource {
  final Dio _dio;

  DriverRemoteDataSource(this._dio);

  Future<DriverProfile> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.driverMe);
      return DriverProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> goOnline() async {
    try {
      await _dio.post(ApiConstants.driverGoOnline);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> goOffline() async {
    try {
      await _dio.post(ApiConstants.driverGoOffline);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> updateLocation({
    required double lat,
    required double lng,
    required double heading,
    required double speed,
  }) async {
    try {
      await _dio.post(
        ApiConstants.driverLocation,
        data: {
          'latitude': lat,
          'longitude': lng,
        },
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<EarningsSummary> getEarnings({DateTime? from, DateTime? to}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (from != null) queryParams['from'] = from.toIso8601String();
      if (to != null) queryParams['to'] = to.toIso8601String();
      final response = await _dio.get(
        ApiConstants.driverEarnings,
        queryParameters: queryParams,
      );
      return EarningsSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<List<DailyEarnings>> getWeeklyEarnings() async {
    try {
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
      final to = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final queryParams = <String, dynamic>{
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      };
      
      final response = await _dio.get(
        ApiConstants.driverEarnings,
        queryParameters: queryParams,
      );
      
      final list = (response.data['dailyBreakdown'] as List?) ?? [];
      return list.map((json) => DailyEarnings.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> startShift() async {
    try {
      await _dio.post(ApiConstants.driverShiftStart);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> endShift() async {
    try {
      await _dio.post(ApiConstants.driverShiftEnd);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    try {
      final response = await _dio.get(ApiConstants.driverExport);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Map<String, dynamic>> verifySelfie(File selfieFile) async {
    try {
      final formData = FormData.fromMap({
        'selfie': await MultipartFile.fromFile(
          selfieFile.path,
          filename: 'selfie.jpg',
        ),
      });
      final response = await _dio.post(
        ApiConstants.driverVerifySelfie,
        data: formData,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<DriverProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (email != null) data['email'] = email;

      final response = await _dio.patch(
        ApiConstants.driverMe,
        data: data,
      );
      return DriverProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      await _dio.post(
        ApiConstants.driverAvatar,
        data: formData,
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> deleteAvatar() async {
    try {
      await _dio.delete(ApiConstants.driverAvatar);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<DriverEarningsBalance> getEarningsBalance() async {
    try {
      final response = await _dio.get(ApiConstants.driverEarningsBalance);
      return DriverEarningsBalance.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Map<String, dynamic>> createWalletPaymentIntent(double amount) async {
    try {
      final response = await _dio.post(
        '/drivers/me/wallet/payment-intent',
        data: {'amount': amount},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<DriverEarningsBalance> addMoney(double amount, {String? paymentIntentId}) async {
    try {
      final response = await _dio.post(
        ApiConstants.driverWalletAddMoney,
        data: {
          'amount': amount,
          if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
        },
      );
      return DriverEarningsBalance.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<DriverEarningsBalance> withdraw(double amount) async {
    try {
      final response = await _dio.post(
        ApiConstants.driverWalletWithdraw,
        data: {'amount': amount},
      );
      return DriverEarningsBalance.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<DriverRatingsResponse> getRatings() async {
    try {
      final response = await _dio.get('${ApiConstants.driverMe}/ratings');
      return DriverRatingsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  ApiException _mapException(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return const BadRequestException();
      case 401:
        return const UnauthorizedException();
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return const ConnectionTimeoutException();
        }
        if (e.type == DioExceptionType.connectionError) {
          return const NetworkException();
        }
        return ServerException(e.message ?? 'Server error');
    }
  }
}
