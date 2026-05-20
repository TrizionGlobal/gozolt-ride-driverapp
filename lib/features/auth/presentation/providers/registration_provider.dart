import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../../domain/models/registration_request.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_result.dart';

class RegistrationState {
  final int currentStep;
  final RegistrationRequest request;
  final bool isLoading;
  final String? errorMessage;
  final bool isOtpSent;
  final bool isOtpVerified;

  RegistrationState({
    this.currentStep = 0,
    required this.request,
    this.isLoading = false,
    this.errorMessage,
    this.isOtpSent = false,
    this.isOtpVerified = false,
  });

  RegistrationState copyWith({
    int? currentStep,
    RegistrationRequest? request,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isOtpSent,
    bool? isOtpVerified,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      request: request ?? this.request,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
    );
  }
}

final registrationProvider = StateNotifierProvider.autoDispose<RegistrationNotifier, RegistrationState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegistrationNotifier(repository);
});

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final AuthRepository _repository;

  RegistrationNotifier(this._repository) : super(RegistrationState(
    request: RegistrationRequest(
      fullName: '',
      phoneNumber: '',
      email: '',
      driverType: 'FLEET',
    ),
  ));

  void setStep(int step) => state = state.copyWith(currentStep: step);
  
  void updateRequest(RegistrationRequest request) => state = state.copyWith(request: request);

  void setFullName(String value) => state = state.copyWith(request: state.request.copyWith(fullName: value));
  void setPhoneNumber(String value) => state = state.copyWith(request: state.request.copyWith(phoneNumber: value));
  void setEmail(String value) => state = state.copyWith(request: state.request.copyWith(email: value));
  void setDriverType(String value) => state = state.copyWith(request: state.request.copyWith(driverType: value));
  void setSupplierCode(String value) => state = state.copyWith(request: state.request.copyWith(supplierCode: value));
  void setPassword(String value) => state = state.copyWith(request: state.request.copyWith(password: value));
  void setVehicleType(String value) => state = state.copyWith(request: state.request.copyWith(vehicleType: value));
  void setVehicleNumber(String value) => state = state.copyWith(request: state.request.copyWith(vehicleNumber: value));
  void setLicensePath(String value) => state = state.copyWith(request: state.request.copyWith(drivingLicensePath: value));
  void setAadhaar(String value) => state = state.copyWith(request: state.request.copyWith(aadhaarNumber: value));
  void setProfileImage(String value) => state = state.copyWith(request: state.request.copyWith(profileImagePath: value));

  // Additional Identity Details
  void setDateOfBirth(String value) => state = state.copyWith(request: state.request.copyWith(dateOfBirth: value));
  void setNationality(String value) => state = state.copyWith(request: state.request.copyWith(nationality: value));
  void setCountryOfResidence(String value) => state = state.copyWith(request: state.request.copyWith(countryOfResidence: value));
  void setNationalId(String value) => state = state.copyWith(request: state.request.copyWith(nationalId: value));
  void setEmergencyContactName(String value) => state = state.copyWith(request: state.request.copyWith(emergencyContactName: value));
  void setEmergencyContactPhone(String value) => state = state.copyWith(request: state.request.copyWith(emergencyContactPhone: value));
  void setHomeAddress(String value) => state = state.copyWith(request: state.request.copyWith(homeAddress: value));

  // Driver Credentials
  void setLicenseNumber(String value) => state = state.copyWith(request: state.request.copyWith(licenseNumber: value));
  void setLicenseCategory(String value) => state = state.copyWith(request: state.request.copyWith(licenseCategory: value));
  void setLicenseIssueDate(String value) => state = state.copyWith(request: state.request.copyWith(licenseIssueDate: value));
  void setLicenseExpiryDate(String value) => state = state.copyWith(request: state.request.copyWith(licenseExpiryDate: value));
  void setLicenseIssuingCountry(String value) => state = state.copyWith(request: state.request.copyWith(licenseIssuingCountry: value));
  void setCpcCertificateNumber(String value) => state = state.copyWith(request: state.request.copyWith(cpcCertificateNumber: value));
  void setTaxiPhvLicenseNumber(String value) => state = state.copyWith(request: state.request.copyWith(taxiPhvLicenseNumber: value));
  void setCpcDocumentPath(String value) => state = state.copyWith(request: state.request.copyWith(cpcDocumentPath: value));

  // Vehicle & Insurance Setters
  void setInsurancePolicyNumber(String value) => state = state.copyWith(request: state.request.copyWith(insurancePolicyNumber: value));
  void setInsuranceDocumentPath(String value) => state = state.copyWith(request: state.request.copyWith(insuranceDocumentPath: value));

  void clearError() => state = state.copyWith(clearError: true);

  Future<bool> sendRegisterOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.sendRegisterOtp(phoneNumber);
    switch (result) {
      case ApiSuccess():
        state = state.copyWith(isLoading: false, isOtpSent: true);
        setPhoneNumber(phoneNumber);
        return true;
      case ApiFailure(:final exception):
        state = state.copyWith(isLoading: false, errorMessage: exception.message);
        return false;
    }
  }

  Future<bool> verifyRegisterOtp(String phoneNumber, String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.verifyRegisterOtp(phoneNumber, otp);
    switch (result) {
      case ApiSuccess():
        state = state.copyWith(isLoading: false, isOtpVerified: true);
        return true;
      case ApiFailure(:final exception):
        state = state.copyWith(isLoading: false, errorMessage: exception.message);
        return false;
    }
  }

  Future<bool> register() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await _repository.register(state.request.toJson());
    
    switch (result) {
      case ApiSuccess():
        state = state.copyWith(isLoading: false);
        return true;
      case ApiFailure(:final exception):
        state = state.copyWith(isLoading: false, errorMessage: exception.message);
        return false;
    }
  }
}
