import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_datasource.dart';
import '../models/daily_earnings.dart';
import '../models/driver_profile.dart';
import '../models/earnings_summary.dart';
import '../models/driver_earnings_balance.dart';
import '../models/driver_ratings_response.dart';

class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource _remoteDataSource;

  static const _devBypass = false;

  static const _dummyProfile = DriverProfile(
    id: 'dev-uuid-001',
    driverId: 'DRV-1024',
    firstName: 'John',
    lastName: 'Borg',
    phone: '+35679123456',
    email: 'john.borg@gmail.com',
    avatarUrl: null,
    rating: 4.8,
    acceptanceRate: 92.5,
    status: 'active',
    vehicle: DriverVehicle(
      id: 'veh-uuid-001',
      make: 'Toyota',
      model: 'Prius',
      plate: 'ABC 123',
      type: 'standard',
    ),
  );

  static const _dummyEarnings = EarningsSummary(
    totalEarnings: 154.75,
    cashEarnings: 89.50,
    cardEarnings: 65.25,
    tripCount: 12,
    cashTripCount: 7,
    cardTripCount: 5,
    tipEarnings: 18.50,
    tipCount: 4,
  );

  DriverRepositoryImpl({required DriverRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<ApiResult<DriverProfile>> getProfile() async {
    if (_devBypass) {
      return const ApiSuccess(_dummyProfile);
    }

    try {
      final profile = await _remoteDataSource.getProfile();
      return ApiSuccess(profile);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> goOnline() async {
    if (_devBypass) {
      return const ApiSuccess(null);
    }

    try {
      await _remoteDataSource.goOnline();
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> goOffline() async {
    if (_devBypass) {
      return const ApiSuccess(null);
    }

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
    if (_devBypass) return;

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
    if (_devBypass) {
      return const ApiSuccess(_dummyEarnings);
    }

    try {
      final earnings = await _remoteDataSource.getEarnings(from: from, to: to);
      return ApiSuccess(earnings);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<List<DailyEarnings>>> getWeeklyEarnings() async {
    if (_devBypass) {
      final now = DateTime.now();
      final dummyWeekly = List.generate(7, (i) {
        final day = now.subtract(Duration(days: 6 - i));
        // Varied dummy data per day
        final earnings = [18.50, 42.00, 35.75, 0.0, 28.00, 15.25, 15.25][i];
        final trips = [2, 5, 4, 0, 3, 2, 2][i];
        final cash = [10.00, 25.00, 20.00, 0.0, 16.00, 8.50, 8.50][i];
        final tips = [2.00, 5.00, 4.50, 0.0, 3.50, 1.50, 2.00][i];
        return DailyEarnings(
          date: DateTime(day.year, day.month, day.day),
          totalEarnings: earnings,
          tripCount: trips,
          cashEarnings: cash,
          cardEarnings: earnings - cash,
          tipEarnings: tips,
        );
      });
      return ApiSuccess(dummyWeekly);
    }

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
    if (_devBypass) {
      return const ApiSuccess(null);
    }

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
    if (_devBypass) {
      return const ApiSuccess(null);
    }

    try {
      await _remoteDataSource.startShift();
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> endShift() async {
    if (_devBypass) {
      return const ApiSuccess(null);
    }

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
  Future<ApiResult<DriverRatingsResponse>> getRatings() async {
    try {
      final ratings = await _remoteDataSource.getRatings();
      return ApiSuccess(ratings);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }
}
