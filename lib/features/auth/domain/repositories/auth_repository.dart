import '../../../../core/network/api_result.dart';
import '../../data/models/login_response.dart';

abstract class AuthRepository {
  Future<ApiResult<void>> sendOtp(String phoneNumber);
  Future<ApiResult<LoginResponse>> verifyOtp(String phoneNumber, String otp);
  Future<void> logout();
  Future<bool> isAuthenticated();
}
