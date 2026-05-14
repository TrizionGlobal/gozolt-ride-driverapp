import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/registration_request.dart';
import 'auth_provider.dart';
import '../../../../core/network/api_result.dart';

class RegistrationState {
  final int currentStep;
  final RegistrationRequest request;
  final bool isLoading;
  final String? errorMessage;

  RegistrationState({
    this.currentStep = 0,
    required this.request,
    this.isLoading = false,
    this.errorMessage,
  });

  RegistrationState copyWith({
    int? currentStep,
    RegistrationRequest? request,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      request: request ?? this.request,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
      password: '',
      vehicleType: 'Car',
      vehicleNumber: '',
    ),
  ));

  void setStep(int step) => state = state.copyWith(currentStep: step);
  
  void updateRequest(RegistrationRequest request) => state = state.copyWith(request: request);

  void setFullName(String value) => state = state.copyWith(request: state.request.copyWith(fullName: value));
  void setPhoneNumber(String value) => state = state.copyWith(request: state.request.copyWith(phoneNumber: value));
  void setEmail(String value) => state = state.copyWith(request: state.request.copyWith(email: value));
  void setPassword(String value) => state = state.copyWith(request: state.request.copyWith(password: value));
  void setVehicleType(String value) => state = state.copyWith(request: state.request.copyWith(vehicleType: value));
  void setVehicleNumber(String value) => state = state.copyWith(request: state.request.copyWith(vehicleNumber: value));
  void setLicensePath(String value) => state = state.copyWith(request: state.request.copyWith(drivingLicensePath: value));
  void setAadhaar(String value) => state = state.copyWith(request: state.request.copyWith(aadhaarNumber: value));
  void setProfileImage(String value) => state = state.copyWith(request: state.request.copyWith(profileImagePath: value));

  Future<bool> register() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await _repository.register(state.request.toJson());
    
    return result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      failure: (exception) {
        state = state.copyWith(isLoading: false, errorMessage: exception.message);
        return false;
      },
    );
  }
}
