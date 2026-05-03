import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginFormState {
  final String driverId;
  final String password;
  final bool rememberMe;
  final bool obscurePassword;
  final String? errorMessage;

  const LoginFormState({
    this.driverId = '',
    this.password = '',
    this.rememberMe = false,
    this.obscurePassword = true,
    this.errorMessage,
  });

  bool get isValid => driverId.isNotEmpty && password.isNotEmpty;

  LoginFormState copyWith({
    String? driverId,
    String? password,
    bool? rememberMe,
    bool? obscurePassword,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginFormState(
      driverId: driverId ?? this.driverId,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      obscurePassword: obscurePassword ?? this.obscurePassword,
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

  void setDriverId(String value) =>
      state = state.copyWith(driverId: value, clearError: true);

  void setPassword(String value) =>
      state = state.copyWith(password: value, clearError: true);

  void toggleRememberMe() =>
      state = state.copyWith(rememberMe: !state.rememberMe);

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void setError(String message) =>
      state = state.copyWith(errorMessage: message);

  void prefillDriverId(String driverId) =>
      state = state.copyWith(driverId: driverId, rememberMe: true);
}
