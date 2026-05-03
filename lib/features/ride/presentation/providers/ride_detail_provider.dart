import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/ride_detail.dart';
import 'ride_provider.dart';

final rideDetailProvider =
    StateNotifierProvider<RideDetailNotifier, RideDetail?>((ref) {
  final repository = ref.watch(rideRepositoryProvider);
  return RideDetailNotifier(repository);
});

class RideDetailNotifier extends StateNotifier<RideDetail?> {
  final dynamic _repository;

  RideDetailNotifier(this._repository) : super(null);

  Future<void> fetchRideDetail(String rideId) async {
    final result = await _repository.getRideDetail(rideId);
    if (result is ApiSuccess<RideDetail>) {
      state = result.data;
    }
  }
}
