class LoginRequest {
  final String driverId;
  final String password;

  const LoginRequest({
    required this.driverId,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'password': password,
      };
}
