import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/models/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/providers/storage_provider.dart';
import '../../../../core/network/api_result.dart';

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
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    final isAuth = await _repository.isAuthenticated();
    state = isAuth ? const AuthAuthenticated() : const AuthUnauthenticated();
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
      case ApiFailure(:final exception):
        state = AuthError(exception.message);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthUnauthenticated();
  }
}
