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

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService storage,
  })  : _remoteDataSource = remoteDataSource,
        _storage = storage;

  @override
  Future<ApiResult<void>> sendRegisterOtp(String phoneNumber) async {
    try {
      await _remoteDataSource.sendRegisterOtp(phoneNumber);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> verifyRegisterOtp(String phoneNumber, String otp) async {
    try {
      await _remoteDataSource.verifyRegisterOtp(phoneNumber, otp);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> sendOtp(String phoneNumber) async {
    try {
      await _remoteDataSource.sendOtp(phoneNumber);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<LoginResponse>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _remoteDataSource.verifyOtp(phoneNumber, otp);
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
  Future<ApiResult<LoginResponse>> loginWithPassword(String driverId, String password) async {
    try {
      final response = await _remoteDataSource.loginWithPassword(driverId, password);
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
  Future<ApiResult<void>> register(Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.register(data);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignore remote logout errors so local logout always completes
    } finally {
      await _storage.clearTokens();
      await _storage.clearOnboardingSeen();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storage.getAccessToken();
    return token != null;
  }

  @override
  Future<ApiResult<void>> forgotPassword(String driverId) async {
    try {
      await _remoteDataSource.forgotPassword(driverId);
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> resetPassword(String driverId, String newPassword) async {
    try {
      await _remoteDataSource.resetPassword(driverId, newPassword);
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(e);
    }
  }
}
