import '../../../../core/network/api_result.dart';
import '../../data/models/login_response.dart';

abstract class AuthRepository {
  Future<ApiResult<LoginResponse>> login({
    required String driverId,
    required String password,
  });
  Future<void> logout();
  Future<bool> isAuthenticated();
}
