import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../driver/data/models/driver_earnings_balance.dart';
import '../../../../driver/data/models/driver_ratings_response.dart';
import '../../../../driver/presentation/providers/driver_provider.dart';

class DriverWalletNotifier extends AutoDisposeAsyncNotifier<DriverEarningsBalance> {
  @override
  Future<DriverEarningsBalance> build() async {
    final repository = ref.watch(driverRepositoryProvider);
    final result = await repository.getEarningsBalance();
    switch (result) {
      case ApiSuccess(:final data):
        return data;
      case ApiFailure(:final exception):
        throw exception;
    }
  }

  Future<bool> addMoney(double amount) async {
    final repository = ref.read(driverRepositoryProvider);
    final result = await repository.addMoney(amount);
    switch (result) {
      case ApiSuccess(:final data):
        state = AsyncData(data);
        return true;
      case ApiFailure():
        return false;
    }
  }

  Future<bool> withdraw(double amount) async {
    final repository = ref.read(driverRepositoryProvider);
    final result = await repository.withdraw(amount);
    switch (result) {
      case ApiSuccess(:final data):
        state = AsyncData(data);
        return true;
      case ApiFailure():
        return false;
    }
  }
}

final walletBalanceProvider = AsyncNotifierProvider.autoDispose<DriverWalletNotifier, DriverEarningsBalance>(() {
  return DriverWalletNotifier();
});

final driverRatingsProvider = FutureProvider.autoDispose<DriverRatingsResponse>((ref) async {
  final repository = ref.watch(driverRepositoryProvider);
  final result = await repository.getRatings();
  switch (result) {
    case ApiSuccess(:final data):
      return data;
    case ApiFailure(:final exception):
      throw exception;
  }
});
