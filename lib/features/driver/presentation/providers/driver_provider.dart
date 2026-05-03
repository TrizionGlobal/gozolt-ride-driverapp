import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/datasources/driver_remote_datasource.dart';
import '../../data/models/driver_profile.dart';
import '../../data/repositories/driver_repository_impl.dart';
import '../../domain/repositories/driver_repository.dart';

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DriverRepositoryImpl(
    remoteDataSource: DriverRemoteDataSource(dio),
  );
});

final driverProfileProvider =
    StateNotifierProvider<DriverProfileNotifier, AsyncValue<DriverProfile>>((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return DriverProfileNotifier(repository);
});

class DriverProfileNotifier extends StateNotifier<AsyncValue<DriverProfile>> {
  final DriverRepository _repository;

  DriverProfileNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchProfile() async {
    state = const AsyncValue.loading();
    final result = await _repository.getProfile();
    switch (result) {
      case ApiSuccess(:final data):
        state = AsyncValue.data(data);
      case ApiFailure(:final exception):
        state = AsyncValue.error(exception.message, StackTrace.current);
    }
  }

  void clearProfile() {
    state = const AsyncValue.loading();
  }
}
