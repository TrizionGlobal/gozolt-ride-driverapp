import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../models/ride.dart';
import '../models/ride_detail.dart';
import '../models/ride_history_item.dart';
import '../models/ride_summary.dart';

class RideRemoteDataSource {
  final Dio _dio;

  RideRemoteDataSource(this._dio);

  /// Unwrap backend response: if wrapped in {"data": {...}}, extract inner map.
  Map<String, dynamic> _unwrap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return responseData;
    }
    return {};
  }

  Future<Ride> getActiveRide() async {
    try {
      final response = await _dio.get(ApiConstants.ridesActive);
      return Ride.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Ride> getRideDetails(String rideId) async {
    try {
      final response = await _dio.get(ApiConstants.rideDetails(rideId));
      if (kDebugMode) print('[RideDataSource] getRideDetails raw: ${response.data}');
      return Ride.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      if (kDebugMode) print('[RideDataSource] getRideDetails error: ${e.response?.statusCode} ${e.response?.data}');
      throw _mapException(e);
    }
  }

  Future<Ride> acceptRide(String rideId) async {
    try {
      final response = await _dio.post(ApiConstants.rideAccept(rideId));
      if (kDebugMode) print('[RideDataSource] acceptRide raw: ${response.data}');
      return Ride.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      if (kDebugMode) print('[RideDataSource] acceptRide error: ${e.response?.statusCode} ${e.response?.data}');
      throw _mapException(e);
    }
  }

  Future<Ride> arriveAtPickup(String rideId) async {
    try {
      final response = await _dio.post(ApiConstants.rideArrive(rideId));
      return Ride.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Ride> startRide(String rideId, {required String otp}) async {
    try {
      // Step 1: Verify OTP
      await _dio.post(
        ApiConstants.rideVerifyOtp(rideId),
        data: {'otp': otp},
      );

      // Step 2: Start the ride
      final response = await _dio.post(ApiConstants.rideStart(rideId));
      return Ride.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<RideSummary> completeRide(String rideId) async {
    try {
      final response = await _dio.post(ApiConstants.rideComplete(rideId));
      return RideSummary.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<RideSummary> getFarePreview(String rideId) async {
    try {
      final response = await _dio.get(ApiConstants.rideFarePreview(rideId));
      return RideSummary.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> respondToRide(String rideId, {required bool accepted}) async {
    try {
      await _dio.post(
        ApiConstants.rideRespond(rideId),
        data: {'accepted': accepted},
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> cancelRide(String rideId, {required String reason}) async {
    try {
      await _dio.post(
        ApiConstants.rideCancel(rideId),
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Ride> nextStop(String rideId) async {
    try {
      final response = await _dio.post(ApiConstants.rideNextStop(rideId));
      return Ride.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<List<RideHistoryItem>> getRideHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.driverRides,
        queryParameters: {'page': page, 'limit': limit},
      );
      final raw = response.data as Map<String, dynamic>;
      final rides = raw['data'] as List<dynamic>? ?? [];
      return rides
          .map((r) => RideHistoryItem.fromJson(r as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Ride?> getDriverActiveRide() async {
    try {
      final response = await _dio.get(ApiConstants.driverActiveRide);
      if (response.data == null) return null;
      return Ride.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _mapException(e);
    }
  }

  Future<RideDetail> getRideDetail(String rideId) async {
    try {
      final response = await _dio.get(ApiConstants.rideDetails(rideId));
      return RideDetail.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> rateRider(String rideId, {required int rating, String? comment}) async {
    try {
      await _dio.post(
        ApiConstants.rideRateRider(rideId),
        data: {'rating': rating, if (comment != null) 'comment': comment},
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Ride> markEnRoute(String rideId) async {
    try {
      final response = await _dio.post(ApiConstants.rideEnRoute(rideId));
      return Ride.fromJson(_unwrap(response.data));
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> reportNoShow(String rideId) async {
    try {
      await _dio.post(ApiConstants.rideNoShow(rideId));
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  ApiException _mapException(DioException e) {
    final body = e.response?.data;
    final msg = body is Map ? (body['message'] ?? body['error'] ?? '') : '';
    switch (e.response?.statusCode) {
      case 400:
        return BadRequestException(msg is String && msg.isNotEmpty ? msg : 'Bad request');
      case 401:
        return const UnauthorizedException();
      case 403:
        return ServerException('Forbidden: $msg');
      case 404:
        return ServerException('Not found: $msg');
      case 409:
        return ServerException('Conflict: $msg');
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return const ConnectionTimeoutException();
        }
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.sendTimeout ||
            (e.type == DioExceptionType.unknown && 
             (e.message?.contains('Failed host lookup') == true || 
              e.message?.contains('SocketException') == true ||
              e.message?.contains('Connection refused') == true))) {
          return const NetworkException();
        }
        return ServerException(e.message ?? 'Server error');
    }
  }
}
