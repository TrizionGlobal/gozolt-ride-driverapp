import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../models/driver_profile.dart';
import '../models/earnings_summary.dart';

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
