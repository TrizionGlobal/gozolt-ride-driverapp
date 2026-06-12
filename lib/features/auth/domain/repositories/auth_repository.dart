import '../../../../core/network/api_result.dart';
import '../../data/models/login_response.dart';

abstract class AuthRepository {
  Future<ApiResult<void>> sendOtp(String phoneNumber);
  Future<ApiResult<LoginResponse>> verifyOtp(String phoneNumber, String otp);
  Future<ApiResult<LoginResponse>> loginWithPassword(String driverId, String password);
  Future<ApiResult<void>> sendRegisterOtp(String phoneNumber);
  Future<ApiResult<void>> verifyRegisterOtp(String phoneNumber, String otp);
  Future<ApiResult<void>> register(Map<String, dynamic> data);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<ApiResult<void>> forgotPassword(String driverId);
  Future<ApiResult<void>> resetPassword(String driverId, String newPassword);
}
