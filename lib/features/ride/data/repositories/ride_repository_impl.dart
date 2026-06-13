import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/repositories/ride_repository.dart';
import '../datasources/ride_remote_datasource.dart';
import '../models/ride.dart';
import '../models/ride_detail.dart';
import '../models/ride_history_item.dart';
import '../models/ride_summary.dart';

class RideRepositoryImpl implements RideRepository {
  final RideRemoteDataSource _remoteDataSource;

  RideRepositoryImpl({required RideRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<ApiResult<Ride>> getActiveRide() async {
    try {
      final ride = await _remoteDataSource.getActiveRide();
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride?>> getDriverActiveRide() async {
    try {
      final ride = await _remoteDataSource.getDriverActiveRide();
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride>> getRideDetails(String rideId) async {
    try {
      final ride = await _remoteDataSource.getRideDetails(rideId);
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride>> acceptRide(String rideId) async {
    try {
      final ride = await _remoteDataSource.acceptRide(rideId);
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride>> arriveAtPickup(String rideId) async {
    try {
      final ride = await _remoteDataSource.arriveAtPickup(rideId);
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride>> startRide(String rideId, {required String otp}) async {
    try {
      final ride = await _remoteDataSource.startRide(rideId, otp: otp);
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<RideSummary>> completeRide(String rideId) async {
    try {
      final summary = await _remoteDataSource.completeRide(rideId);
      return ApiSuccess(summary);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<RideSummary>> getFarePreview(String rideId) async {
    try {
      final summary = await _remoteDataSource.getFarePreview(rideId);
      return ApiSuccess(summary);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> respondToRide(String rideId, {required bool accepted}) async {
    try {
      await _remoteDataSource.respondToRide(rideId, accepted: accepted);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> cancelRide(String rideId, {required String reason}) async {
    try {
      await _remoteDataSource.cancelRide(rideId, reason: reason);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride>> nextStop(String rideId) async {
    try {
      final ride = await _remoteDataSource.nextStop(rideId);
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<List<RideHistoryItem>>> getRideHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final items = await _remoteDataSource.getRideHistory(
        page: page,
        limit: limit,
      );
      return ApiSuccess(items);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<RideDetail>> getRideDetail(String rideId) async {
    try {
      final detail = await _remoteDataSource.getRideDetail(rideId);
      return ApiSuccess(detail);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> rateRider(String rideId, {required int rating, String? comment}) async {
    try {
      await _remoteDataSource.rateRider(rideId, rating: rating, comment: comment);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride>> markEnRoute(String rideId) async {
    try {
      final ride = await _remoteDataSource.markEnRoute(rideId);
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> reportNoShow(String rideId) async {
    try {
      await _remoteDataSource.reportNoShow(rideId);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }
}
