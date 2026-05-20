class RegistrationRequest {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String driverType; // 'FLEET' or 'SELF_OWNED'
  final String? supplierCode;
  final String? password;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? drivingLicensePath;
  final String? aadhaarNumber;
  final String? profileImagePath;

  // Identity / Contact Info
  final String? dateOfBirth;
  final String? nationality;
  final String? countryOfResidence;
  final String? nationalId;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? homeAddress;

  // Driver Credentials
  final String? licenseNumber;
  final String? licenseCategory;
  final String? licenseIssueDate;
  final String? licenseExpiryDate;
  final String? licenseIssuingCountry;
  final String? cpcCertificateNumber;
  final String? taxiPhvLicenseNumber;
  final String? cpcDocumentPath;

  // Vehicle & Insurance
  final String? insurancePolicyNumber;
  final String? insuranceDocumentPath;

  RegistrationRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.driverType,
    this.supplierCode,
    this.password,
    this.vehicleType,
    this.vehicleNumber,
    this.drivingLicensePath,
    this.aadhaarNumber,
    this.profileImagePath,
    this.dateOfBirth,
    this.nationality,
    this.countryOfResidence,
    this.nationalId,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.homeAddress,
    this.licenseNumber,
    this.licenseCategory,
    this.licenseIssueDate,
    this.licenseExpiryDate,
    this.licenseIssuingCountry,
    this.cpcCertificateNumber,
    this.taxiPhvLicenseNumber,
    this.cpcDocumentPath,
    this.insurancePolicyNumber,
    this.insuranceDocumentPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'driverType': driverType,
      if (supplierCode != null) 'supplierCode': supplierCode,
      if (password != null) 'password': password,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (vehicleNumber != null) 'vehicleNumber': vehicleNumber,
      'drivingLicense': drivingLicensePath,
      'aadhaarNumber': aadhaarNumber ?? nationalId,
      'profileImage': profileImagePath,
      'dateOfBirth': dateOfBirth,
      'nationality': nationality,
      'countryOfResidence': countryOfResidence,
      'nationalId': nationalId,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'homeAddress': homeAddress,
      'licenseNumber': licenseNumber,
      'licenseCategory': licenseCategory,
      'licenseIssueDate': licenseIssueDate,
      'licenseExpiryDate': licenseExpiryDate,
      'licenseIssuingCountry': licenseIssuingCountry,
      'cpcCertificateNumber': cpcCertificateNumber,
      'taxiPhvLicenseNumber': taxiPhvLicenseNumber,
      'cpcDocument': cpcDocumentPath,
      'insurancePolicyNumber': insurancePolicyNumber,
      'insuranceDocument': insuranceDocumentPath,
    };
  }

  RegistrationRequest copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? driverType,
    String? supplierCode,
    String? password,
    String? vehicleType,
    String? vehicleNumber,
    String? drivingLicensePath,
    String? aadhaarNumber,
    String? profileImagePath,
    String? dateOfBirth,
    String? nationality,
    String? countryOfResidence,
    String? nationalId,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? homeAddress,
    String? licenseNumber,
    String? licenseCategory,
    String? licenseIssueDate,
    String? licenseExpiryDate,
    String? licenseIssuingCountry,
    String? cpcCertificateNumber,
    String? taxiPhvLicenseNumber,
    String? cpcDocumentPath,
    String? insurancePolicyNumber,
    String? insuranceDocumentPath,
  }) {
    return RegistrationRequest(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      driverType: driverType ?? this.driverType,
      supplierCode: supplierCode ?? this.supplierCode,
      password: password ?? this.password,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      drivingLicensePath: drivingLicensePath ?? this.drivingLicensePath,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      countryOfResidence: countryOfResidence ?? this.countryOfResidence,
      nationalId: nationalId ?? this.nationalId,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      homeAddress: homeAddress ?? this.homeAddress,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseCategory: licenseCategory ?? this.licenseCategory,
      licenseIssueDate: licenseIssueDate ?? this.licenseIssueDate,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      licenseIssuingCountry: licenseIssuingCountry ?? this.licenseIssuingCountry,
      cpcCertificateNumber: cpcCertificateNumber ?? this.cpcCertificateNumber,
      taxiPhvLicenseNumber: taxiPhvLicenseNumber ?? this.taxiPhvLicenseNumber,
      cpcDocumentPath: cpcDocumentPath ?? this.cpcDocumentPath,
      insurancePolicyNumber: insurancePolicyNumber ?? this.insurancePolicyNumber,
      insuranceDocumentPath: insuranceDocumentPath ?? this.insuranceDocumentPath,
    );
  }
}
