import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/ride_history_item.dart';
import 'ride_provider.dart';

final rideHistoryProvider =
    StateNotifierProvider<RideHistoryNotifier, List<RideHistoryItem>>((ref) {
  final repository = ref.watch(rideRepositoryProvider);
  return RideHistoryNotifier(repository);
});

class RideHistoryNotifier extends StateNotifier<List<RideHistoryItem>> {
  final dynamic _repository;

  RideHistoryNotifier(this._repository) : super(const []);

  Future<void> fetchRides({int page = 1, int limit = 20}) async {
    final result = await _repository.getRideHistory(page: page, limit: limit);
    if (result is ApiSuccess<List<RideHistoryItem>>) {
      state = result.data;
    }
  }
}
