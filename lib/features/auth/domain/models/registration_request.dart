class RegistrationRequest {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String password;
  final String vehicleType;
  final String vehicleNumber;
  final String? drivingLicensePath;
  final String? aadhaarNumber;
  final String? profileImagePath;

  RegistrationRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.vehicleType,
    required this.vehicleNumber,
    this.drivingLicensePath,
    this.aadhaarNumber,
    this.profileImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'drivingLicense': drivingLicensePath,
      'aadhaarNumber': aadhaarNumber,
      'profileImage': profileImagePath,
    };
  }

  RegistrationRequest copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? password,
    String? vehicleType,
    String? vehicleNumber,
    String? drivingLicensePath,
    String? aadhaarNumber,
    String? profileImagePath,
  }) {
    return RegistrationRequest(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      drivingLicensePath: drivingLicensePath ?? this.drivingLicensePath,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
