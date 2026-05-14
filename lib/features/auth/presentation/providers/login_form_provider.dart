import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginFormState {
  final String dialCode;
  final String phoneNumber;
  final String verificationId;
  final bool rememberMe;
  final String? errorMessage;

  const LoginFormState({
    this.dialCode = '+356',
    this.phoneNumber = '',
    this.verificationId = '',
    this.rememberMe = false,
    this.errorMessage,
  });

  bool get isValid => phoneNumber.isNotEmpty && phoneNumber.length >= 7;
  String get fullPhoneNumber => '$dialCode$phoneNumber';

  LoginFormState copyWith({
    String? dialCode,
    String? phoneNumber,
    String? verificationId,
    bool? rememberMe,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginFormState(
      dialCode: dialCode ?? this.dialCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
  return LoginFormNotifier();
});

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  LoginFormNotifier() : super(const LoginFormState());

  void setDialCode(String value) =>
      state = state.copyWith(dialCode: value, clearError: true);

  void setPhoneNumber(String value) =>
      state = state.copyWith(phoneNumber: value, clearError: true);

  void setVerificationId(String value) =>
      state = state.copyWith(verificationId: value);

  void toggleRememberMe() =>
      state = state.copyWith(rememberMe: !state.rememberMe);

  void setError(String message) =>
      state = state.copyWith(errorMessage: message);

  void prefillPhoneNumber(String phoneNumber) =>
      state = state.copyWith(phoneNumber: phoneNumber, rememberMe: true);
}
