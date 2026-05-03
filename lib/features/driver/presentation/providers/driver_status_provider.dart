import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/socket_service.dart';
import '../../data/models/driver_status.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_provider.dart';

final driverStatusProvider =
    StateNotifierProvider<DriverStatusNotifier, DriverStatus>((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  final socketService = ref.watch(socketServiceProvider);
  return DriverStatusNotifier(repository, socketService);
});

class DriverStatusNotifier extends StateNotifier<DriverStatus> {
  final DriverRepository _repository;
  final SocketService _socketService;

  DriverStatusNotifier(this._repository, this._socketService)
      : super(DriverStatus.offline);

  Future<bool> goOnline({String? token}) async {
    if (kDebugMode) print('[DriverStatus] goOnline called, token=${token != null ? '${token.substring(0, 20)}...' : 'NULL'}');
    final ApiResult<void> result = await _repository.goOnline();
    if (kDebugMode) print('[DriverStatus] goOnline API result: $result');
    return switch (result) {
      ApiSuccess() => () {
          state = DriverStatus.online;
          if (token != null) {
            if (kDebugMode) print('[DriverStatus] API success, now connecting socket with token...');
            _socketService.connect(token);
          } else {
            if (kDebugMode) print('[DriverStatus] API success but NO TOKEN — socket NOT connected!');
          }
          return true;
        }(),
      ApiFailure() => () {
          if (kDebugMode) print('[DriverStatus] goOnline API FAILED');
          return false;
        }(),
    };
  }

  Future<bool> goOffline() async {
    final ApiResult<void> result = await _repository.goOffline();
    return switch (result) {
      ApiSuccess() => () {
          state = DriverStatus.offline;
          _socketService.disconnect();
          return true;
        }(),
      ApiFailure() => false,
    };
  }

  void setOnRide() {
    state = DriverStatus.onRide;
  }
}
