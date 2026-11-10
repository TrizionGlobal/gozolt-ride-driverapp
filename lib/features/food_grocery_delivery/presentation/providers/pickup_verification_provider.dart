import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../domain/models/pickup_verification_method.dart';
import '../../domain/models/pickup_verification_result.dart';

class PickupVerificationState {
  const PickupVerificationState({
    required this.serviceType,
    this.selectedMethod = PickupVerificationMethod.pickupPin,
    this.result = PickupVerificationResult.idle,
    this.enteredPin = '',
    this.failedAttempts = 0,
    this.errorMessage,
  });

  static const int maximumAttempts = 3;

  final PartnerServiceType serviceType;
  final PickupVerificationMethod selectedMethod;
  final PickupVerificationResult result;

  /// Held only in temporary UI state. Never persist or log this value.
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
    return enteredPin.length == 4 && !isVerifying && !isLocked;
  }

  int get remainingAttempts {
    final remaining = maximumAttempts - failedAttempts;
    return remaining < 0 ? 0 : remaining;
  }

  PickupVerificationState copyWith({
    PickupVerificationMethod? selectedMethod,
    PickupVerificationResult? result,
    String? enteredPin,
    int? failedAttempts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PickupVerificationState(
      serviceType: serviceType,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      result: result ?? this.result,
      enteredPin: enteredPin ?? this.enteredPin,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PickupVerificationNotifier
    extends StateNotifier<PickupVerificationState> {
  PickupVerificationNotifier(
    PartnerServiceType serviceType,
  ) : super(
          PickupVerificationState(
            serviceType: serviceType,
          ),
        );

  void selectMethod(
    PickupVerificationMethod method,
  ) {
    if (state.isVerifying || state.isVerified || state.isLocked) {
      return;
    }

    state = state.copyWith(
      selectedMethod: method,
      result: PickupVerificationResult.idle,
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
      result: PickupVerificationResult.idle,
      clearError: true,
    );
  }

  Future<bool> verifyPin() async {
    if (!state.canSubmitPin) {
      if (state.enteredPin.length != 4 && !state.isLocked) {
        state = state.copyWith(
          result: PickupVerificationResult.failed,
          errorMessage: 'Enter the complete 4-digit pickup PIN.',
        );
      }

      return false;
    }

    state = state.copyWith(
      selectedMethod: PickupVerificationMethod.pickupPin,
      result: PickupVerificationResult.verifying,
      clearError: true,
    );

    // TODO(FOOD_GROCERY_API):
    // Send the PIN securely to the pickup-verification endpoint.
    // The backend must validate the delivery, supplier, partner,
    // token expiry and attempt limit.
    //
    // The temporary demonstration PIN must be removed when the
    // backend endpoint is connected.
    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    const temporaryDemoPin = '2468';

    if (state.enteredPin == temporaryDemoPin) {
      state = state.copyWith(
        result: PickupVerificationResult.verified,
        enteredPin: '',
        clearError: true,
      );

      return true;
    }

    final failedAttempts = state.failedAttempts + 1;
    final isNowLocked =
        failedAttempts >= PickupVerificationState.maximumAttempts;

    state = state.copyWith(
      result: isNowLocked
          ? PickupVerificationResult.locked
          : PickupVerificationResult.failed,
      enteredPin: '',
      failedAttempts: failedAttempts,
      errorMessage: isNowLocked
          ? 'Pickup verification is temporarily locked. Contact support.'
          : 'Incorrect pickup PIN. '
              '${PickupVerificationState.maximumAttempts - failedAttempts} '
              'attempts remaining.',
    );

    return false;
  }

  void setError(String message) {
    if (state.isVerified) {
      return;
    }

    state = state.copyWith(
      result: PickupVerificationResult.failed,
      errorMessage: message,
    );
  }

  void reset() {
    state = PickupVerificationState(
      serviceType: state.serviceType,
    );
  }
}

final pickupVerificationProvider = StateNotifierProvider.family<
    PickupVerificationNotifier, PickupVerificationState, PartnerServiceType>(
  (ref, serviceType) {
    assert(
      serviceType == PartnerServiceType.foodDelivery ||
          serviceType == PartnerServiceType.groceryDelivery,
      'Pickup verification supports only Food or Grocery deliveries.',
    );

    return PickupVerificationNotifier(
      serviceType,
    );
  },
);
