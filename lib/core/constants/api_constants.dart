abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.12:3000/v1',
  );

  // Auth endpoints
  static const String loginDriver = '/auth/driver/login';
  static const String registerDriver = '/auth/driver/register';
  static const String sendRegisterOtp = '/auth/driver/register/send-otp';
  static const String verifyRegisterOtp = '/auth/driver/register/verify-otp';
  static const String sendOtp = '/auth/driver/send-otp';
  static const String verifyOtp = '/auth/driver/verify-otp';
  static const String checkPhone = '/auth/driver/check-phone';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';

  // Driver endpoints
  static const String driverMe = '/drivers/me';
  static const String driverGoOnline = '/drivers/me/go-online';
  static const String driverGoOffline = '/drivers/me/go-offline';
  static const String driverLocation = '/drivers/me/location';

  // Earnings endpoints
  static const String driverEarnings = '/drivers/me/earnings';
  static const String driverEarningsBalance = '/drivers/me/earnings/balance';

  // Driver ride history
  static const String driverRides = '/drivers/me/rides';

  // Driver active ride
  static const String driverActiveRide = '/drivers/me/active-ride';

  // Ride endpoints
  static const String ridesActive = '/rides/active';
  static const String ridesHistory = '/rides/history';
  static String rideDetails(String id) => '/rides/$id';
  static String rideAccept(String id) => '/rides/$id/accept';
  static String rideRespond(String id) => '/rides/$id/respond';
  static String rideEnRoute(String id) => '/rides/$id/en-route';
  static String rideArrive(String id) => '/rides/$id/arrive';
  static String rideVerifyOtp(String id) => '/rides/$id/verify-otp';
  static String rideStart(String id) => '/rides/$id/start';
  static String rideComplete(String id) => '/rides/$id/complete';
  static String rideCancel(String id) => '/rides/$id/cancel';
  static String rideNextStop(String id) => '/rides/$id/next-stop';
  static String rideNoShow(String id) => '/rides/$id/no-show';
  static String rideRateRider(String id) => '/rides/$id/rate-rider';

  // Shift endpoints
  static const String driverShiftStart = '/drivers/me/shift/start';
  static const String driverShiftEnd = '/drivers/me/shift/end';

  // Selfie verification
  static const String driverVerifySelfie = '/drivers/me/verify-selfie';

  // Data export
  static const String driverExport = '/drivers/me/export';

  // Notification endpoints
  static const String notifications = '/users/me/notifications';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
