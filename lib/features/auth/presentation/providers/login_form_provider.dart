import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginFormState {
  final String driverId;
  final String password;
  final bool rememberMe;
  final String? errorMessage;

  const LoginFormState({
    this.driverId = '',
    this.password = '',
    this.rememberMe = false,
    this.errorMessage,
  });

  bool get isValid => driverId.trim().isNotEmpty && password.trim().length >= 6;
  String get fullPhoneNumber => '';

  LoginFormState copyWith({
    String? driverId,
    String? password,
    bool? rememberMe,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginFormState(
      driverId: driverId ?? this.driverId,
      password: password ?? this.password,
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

  void setDriverId(String value) =>
      state = state.copyWith(driverId: value, clearError: true);

  void setPassword(String value) =>
      state = state.copyWith(password: value, clearError: true);

  void toggleRememberMe() =>
      state = state.copyWith(rememberMe: !state.rememberMe);

  void setError(String message) =>
      state = state.copyWith(errorMessage: message);

  void prefillDriverId(String driverId) =>
      state = state.copyWith(driverId: driverId, rememberMe: true);
}
