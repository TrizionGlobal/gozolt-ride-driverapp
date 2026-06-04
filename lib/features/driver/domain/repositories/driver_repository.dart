import '../../../../core/network/api_result.dart';
import '../../data/models/driver_profile.dart';
import '../../data/models/daily_earnings.dart';
import '../../data/models/earnings_summary.dart';
import '../../data/models/driver_earnings_balance.dart';
import '../../data/models/driver_ratings_response.dart';

abstract class DriverRepository {
  Future<ApiResult<DriverProfile>> getProfile();
  Future<ApiResult<void>> goOnline();
  Future<ApiResult<void>> goOffline();
  Future<void> updateLocation({
    required double lat,
    required double lng,
    required double heading,
    required double speed,
  });
  Future<ApiResult<EarningsSummary>> getEarnings({DateTime? from, DateTime? to});
  Future<ApiResult<List<DailyEarnings>>> getWeeklyEarnings();
  Future<ApiResult<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<ApiResult<void>> startShift();
  Future<ApiResult<void>> endShift();
  Future<ApiResult<DriverProfile>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  });
  Future<ApiResult<void>> uploadAvatar(String filePath);
  Future<ApiResult<void>> deleteAvatar();
  Future<ApiResult<DriverEarningsBalance>> getEarningsBalance();
  Future<ApiResult<DriverEarningsBalance>> addMoney(double amount, {String? paymentIntentId});
  Future<ApiResult<Map<String, dynamic>>> createWalletPaymentIntent(double amount);
  Future<ApiResult<DriverEarningsBalance>> withdraw(double amount);
  Future<ApiResult<DriverRatingsResponse>> getRatings();
}
