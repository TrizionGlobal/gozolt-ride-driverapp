import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/models/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/storage_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/services/notification_service.dart';
import '../../../driver/presentation/providers/driver_status_provider.dart';
import '../../../driver/presentation/providers/driver_provider.dart';
import '../../../driver/presentation/providers/earnings_provider.dart';
import '../../../home/presentation/home_shell.dart';
import '../../../ride/presentation/providers/ride_session_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(dio),
    storage: storage,
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    final isAuth = await _repository.isAuthenticated();
    state = isAuth ? const AuthAuthenticated() : const AuthUnauthenticated();
    if (isAuth) {
      _ref.read(notificationServiceProvider).updateToken().ignore();
    }
  }

  Future<bool> loginWithPassword({
    required String driverId,
    required String password,
  }) async {
    state = const AuthLoading();
    final result = await _repository.loginWithPassword(driverId, password);
    switch (result) {
      case ApiSuccess():
        state = const AuthAuthenticated();
        _ref.read(notificationServiceProvider).updateToken().ignore();
        return true;
      case ApiFailure(:final exception):
        state = AuthError(exception.message);
        return false;
    }
  }

  Future<bool> sendOtp(String phoneNumber) async {
    state = const AuthLoading();
    final result = await _repository.sendOtp(phoneNumber);
    switch (result) {
      case ApiSuccess():
        state = const AuthUnauthenticated(); // Stay on login but show success
        return true;
      case ApiFailure(:final exception):
        state = AuthError(exception.message);
        return false;
    }
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    state = const AuthLoading();
    final result = await _repository.verifyOtp(
      phoneNumber,
      otp,
    );
    switch (result) {
      case ApiSuccess():
        state = const AuthAuthenticated();
        _ref.read(notificationServiceProvider).updateToken().ignore();
      case ApiFailure(:final exception):
        state = AuthError(exception.message);
    }
  }

  Future<void> logout() async {
    // Before actually logging out, set driver to offline if possible to stop location tracking gracefully
    _ref.read(driverStatusProvider.notifier).state = const DriverStatus(isOnline: false, isOnRide: false);

    await _repository.logout();
    state = const AuthUnauthenticated();

    // Invalidate state to prevent data leaking to next session or crashing background services
    _ref.invalidate(homeTabIndexProvider);
    _ref.invalidate(driverStatusProvider);
    _ref.invalidate(driverProfileProvider);
    _ref.invalidate(todayEarningsProvider);
    _ref.invalidate(earningsScreenProvider);
    _ref.invalidate(rideSessionProvider);
  }
}
