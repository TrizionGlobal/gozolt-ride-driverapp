import '../../../../core/network/api_result.dart';
import '../../data/models/ride.dart';
import '../../data/models/ride_detail.dart';
import '../../data/models/ride_history_item.dart';
import '../../data/models/ride_summary.dart';

abstract class RideRepository {
  Future<ApiResult<Ride>> getActiveRide();
  Future<ApiResult<Ride?>> getDriverActiveRide();
  Future<ApiResult<Ride>> getRideDetails(String rideId);
  Future<ApiResult<Ride>> acceptRide(String rideId);
  Future<ApiResult<Ride>> arriveAtPickup(String rideId);
  Future<ApiResult<Ride>> startRide(String rideId, {required String otp});
  Future<ApiResult<RideSummary>> completeRide(String rideId);
  Future<ApiResult<void>> respondToRide(String rideId, {required bool accepted});
  Future<ApiResult<void>> cancelRide(String rideId, {required String reason});
  Future<ApiResult<Ride>> nextStop(String rideId);
  Future<ApiResult<List<RideHistoryItem>>> getRideHistory({int page, int limit});
  Future<ApiResult<RideDetail>> getRideDetail(String rideId);
  Future<ApiResult<void>> rateRider(String rideId, {required int rating, String? comment});
  Future<ApiResult<void>> reportNoShow(String rideId);
  Future<ApiResult<Ride>> markEnRoute(String rideId);
}
