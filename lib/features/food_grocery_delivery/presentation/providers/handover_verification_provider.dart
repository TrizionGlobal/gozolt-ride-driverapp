import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../domain/models/handover_verification_method.dart';
import '../../domain/models/handover_verification_result.dart';

class HandoverVerificationState {
  const HandoverVerificationState({
    required this.serviceType,
    this.selectedMethod = HandoverVerificationMethod.deliveryPin,
    this.result = HandoverVerificationResult.idle,
    this.enteredPin = '',
    this.failedAttempts = 0,
    this.errorMessage,
  });

  static const int maximumAttempts = 3;

  final PartnerServiceType serviceType;
  final HandoverVerificationMethod selectedMethod;
  final HandoverVerificationResult result;

  /// Temporary UI state only. Never persist or log this value.
  final String enteredPin;

  final int failedAttempts;
  final String? errorMessage;

  bool get isVerifying {
    return result.isVerifying;
  }

  bool get isVerified {
    return result.isVerified;
  }

  bool get isLocked {
    return result.isLocked;
  }

  bool get canSubmitPin {
    return enteredPin.length == 4 && !isVerifying && !isVerified && !isLocked;
  }

  int get remainingAttempts {
    final remaining = maximumAttempts - failedAttempts;
    return remaining < 0 ? 0 : remaining;
  }

  HandoverVerificationState copyWith({
    HandoverVerificationMethod? selectedMethod,
    HandoverVerificationResult? result,
    String? enteredPin,
    int? failedAttempts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HandoverVerificationState(
      serviceType: serviceType,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      result: result ?? this.result,
      enteredPin: enteredPin ?? this.enteredPin,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class HandoverVerificationNotifier
    extends StateNotifier<HandoverVerificationState> {
  HandoverVerificationNotifier(
    PartnerServiceType serviceType,
  ) : super(
          HandoverVerificationState(
            serviceType: serviceType,
          ),
        );

  void selectMethod(
    HandoverVerificationMethod method,
  ) {
    if (state.isVerifying || state.isVerified || state.isLocked) {
      return;
    }

    state = state.copyWith(
      selectedMethod: method,
      result: HandoverVerificationResult.idle,
      clearError: true,
    );
  }

  void updatePin(String value) {
    if (state.isVerifying || state.isVerified || state.isLocked) {
      return;
    }

    final digitsOnly = value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    final normalizedPin =
        digitsOnly.length > 4 ? digitsOnly.substring(0, 4) : digitsOnly;

    state = state.copyWith(
      enteredPin: normalizedPin,
      result: HandoverVerificationResult.idle,
      clearError: true,
    );
  }

  Future<bool> verifyPin() async {
    if (!state.canSubmitPin) {
      if (state.enteredPin.length != 4 &&
          !state.isLocked &&
          !state.isVerified) {
        state = state.copyWith(
          result: HandoverVerificationResult.failed,
          errorMessage: 'Enter the complete 4-digit delivery PIN.',
        );
      }

      return false;
    }

    state = state.copyWith(
      selectedMethod: HandoverVerificationMethod.deliveryPin,
      result: HandoverVerificationResult.verifying,
      clearError: true,
    );

    // TODO(FOOD_GROCERY_API):
    // Send the delivery PIN securely to the customer-handover endpoint.
    // The PIN must be verified by the backend and must never be logged.
    //
    // Remove the temporary demonstration PIN when the API is connected.
    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    const temporaryDemoPin = '1357';

    if (state.enteredPin == temporaryDemoPin) {
      state = state.copyWith(
        result: HandoverVerificationResult.verified,
        enteredPin: '',
        clearError: true,
      );

      return true;
    }

    final failedAttempts = state.failedAttempts + 1;
    final isNowLocked =
        failedAttempts >= HandoverVerificationState.maximumAttempts;

    state = state.copyWith(
      result: isNowLocked
          ? HandoverVerificationResult.locked
          : HandoverVerificationResult.failed,
      enteredPin: '',
      failedAttempts: failedAttempts,
      errorMessage: isNowLocked
          ? 'Delivery verification is temporarily locked. Contact support.'
          : 'Incorrect delivery PIN. '
              '${HandoverVerificationState.maximumAttempts - failedAttempts} '
              'attempts remaining.',
    );

    return false;
  }

  void setError(String message) {
    if (state.isVerified) {
      return;
    }

    state = state.copyWith(
      result: HandoverVerificationResult.failed,
      errorMessage: message,
    );
  }

  void reset() {
    state = HandoverVerificationState(
      serviceType: state.serviceType,
    );
  }
}

final handoverVerificationProvider = StateNotifierProvider.family<
    HandoverVerificationNotifier,
    HandoverVerificationState,
    PartnerServiceType>(
  (ref, serviceType) {
    assert(
      serviceType == PartnerServiceType.foodDelivery ||
          serviceType == PartnerServiceType.groceryDelivery,
      'Handover verification supports only Food or Grocery deliveries.',
    );

    return HandoverVerificationNotifier(
      serviceType,
    );
  },
);
