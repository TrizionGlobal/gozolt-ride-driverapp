import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_datasource.dart';
import '../models/daily_earnings.dart';
import '../models/driver_profile.dart';
import '../models/earnings_summary.dart';
import '../models/driver_earnings_balance.dart';
import '../models/driver_ratings_response.dart';
import '../models/driver_payout_log.dart';

class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource _remoteDataSource;

  DriverRepositoryImpl({required DriverRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<ApiResult<DriverProfile>> getProfile() async {
    try {
      final profile = await _remoteDataSource.getProfile();
      return ApiSuccess(profile);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> goOnline() async {
    try {
      await _remoteDataSource.goOnline();
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> goOffline() async {
    try {
      await _remoteDataSource.goOffline();
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<void> updateLocation({
    required double lat,
    required double lng,
    required double heading,
    required double speed,
  }) async {
    try {
      await _remoteDataSource.updateLocation(
        lat: lat,
        lng: lng,
        heading: heading,
        speed: speed,
      );
    } on ApiException {
      // Location updates are fire-and-forget; don't propagate errors
    }
  }

  @override
  Future<ApiResult<EarningsSummary>> getEarnings({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final earnings = await _remoteDataSource.getEarnings(from: from, to: to);
      return ApiSuccess(earnings);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<List<DailyEarnings>>> getWeeklyEarnings() async {
    try {
      final weeklyEarnings = await _remoteDataSource.getWeeklyEarnings();
      return ApiSuccess(weeklyEarnings);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> startShift() async {
    try {
      await _remoteDataSource.startShift();
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> endShift() async {
    try {
      await _remoteDataSource.endShift();
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<DriverProfile>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? payoutBankName,
    String? payoutAccountNumber,
    String? payoutAccountHolder,
    String? payoutSwiftCode,
  }) async {
    try {
      final profile = await _remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        payoutBankName: payoutBankName,
        payoutAccountNumber: payoutAccountNumber,
        payoutAccountHolder: payoutAccountHolder,
        payoutSwiftCode: payoutSwiftCode,
      );
      return ApiSuccess(profile);
    } on ApiException catch (e) {
      return ApiFailure(e);
    } catch (e) {
      return ApiFailure(ServerException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> uploadAvatar(String filePath) async {
    try {
      await _remoteDataSource.uploadAvatar(filePath);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> deleteAvatar() async {
    try {
      await _remoteDataSource.deleteAvatar();
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<DriverEarningsBalance>> getEarningsBalance() async {
    try {
      final balance = await _remoteDataSource.getEarningsBalance();
      return ApiSuccess(balance);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<DriverEarningsBalance>> addMoney(double amount, {String? paymentIntentId}) async {
    try {
      final balance = await _remoteDataSource.addMoney(amount, paymentIntentId: paymentIntentId);
      return ApiSuccess(balance);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> createWalletPaymentIntent(double amount) async {
    try {
      final data = await _remoteDataSource.createWalletPaymentIntent(amount);
      return ApiSuccess(data);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<DriverEarningsBalance>> withdraw(double amount) async {
    try {
      final balance = await _remoteDataSource.withdraw(amount);
      return ApiSuccess(balance);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<DriverEarningsBalance>> withdrawTips(double amount) async {
    try {
      final balance = await _remoteDataSource.withdrawTips(amount);
      return ApiSuccess(balance);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<List<DriverPayoutLog>>> getWithdrawals() async {
    try {
      final logs = await _remoteDataSource.getWithdrawals();
      return ApiSuccess(logs);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<DriverRatingsResponse>> getRatings() async {
    try {
      final ratings = await _remoteDataSource.getRatings();
      return ApiSuccess(ratings);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }
}
