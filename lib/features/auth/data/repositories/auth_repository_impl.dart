import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storage;

  static const _devBypassLogin = false;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService storage,
  })  : _remoteDataSource = remoteDataSource,
        _storage = storage;

  @override
  Future<ApiResult<LoginResponse>> login({
    required String driverId,
    required String password,
  }) async {
    if (_devBypassLogin) {
      const fakeResponse = LoginResponse(
        accessToken: 'dev_access_token',
        refreshToken: 'dev_refresh_token',
      );
      await _storage.saveTokens(
        accessToken: fakeResponse.accessToken,
        refreshToken: fakeResponse.refreshToken,
      );
      return const ApiSuccess(fakeResponse);
    }

    try {
      final response = await _remoteDataSource.login(
        LoginRequest(driverId: driverId, password: password),
      );
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return ApiSuccess(response);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _storage.clearTokens();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storage.getAccessToken();
    return token != null;
  }
}
