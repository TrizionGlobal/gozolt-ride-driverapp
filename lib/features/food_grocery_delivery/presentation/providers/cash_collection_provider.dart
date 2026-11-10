import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../partner_services/domain/models/partner_service_type.dart';

class CashCollectionState {
  const CashCollectionState({
    required this.serviceType,
    this.isConfirming = false,
    this.isCollected = false,
    this.errorMessage,
  });

  final PartnerServiceType serviceType;
  final bool isConfirming;
  final bool isCollected;
  final String? errorMessage;

  bool get canConfirm {
    return !isConfirming && !isCollected;
  }

  CashCollectionState copyWith({
    bool? isConfirming,
    bool? isCollected,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CashCollectionState(
      serviceType: serviceType,
      isConfirming: isConfirming ?? this.isConfirming,
      isCollected: isCollected ?? this.isCollected,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class CashCollectionNotifier extends StateNotifier<CashCollectionState> {
  CashCollectionNotifier(
    PartnerServiceType serviceType,
  ) : super(
          CashCollectionState(
            serviceType: serviceType,
          ),
        );

  Future<bool> confirmCashCollected({
    required String deliveryId,
    required double amount,
  }) async {
    if (!state.canConfirm) {
      return state.isCollected;
    }

    if (deliveryId.trim().isEmpty || amount <= 0) {
      state = state.copyWith(
        isConfirming: false,
        errorMessage: 'The cash collection details are not valid.',
      );
      return false;
    }

    state = state.copyWith(
      isConfirming: true,
      clearError: true,
    );

    // TODO(FOOD_GROCERY_API):
    // Replace this delay with the cash-collection confirmation endpoint.
    //
    // The backend must validate:
    // - delivery ID,
    // - assigned partner ID,
    // - payment method,
    // - exact amount due,
    // - customer handover verification,
    // - duplicate collection attempts.
    //
    // Cash collection must be included in partner settlement and
    // reconciliation records. Never treat collected cash as earnings.
    await Future<void>.delayed(
      const Duration(milliseconds: 750),
    );

    state = state.copyWith(
      isConfirming: false,
      isCollected: true,
      clearError: true,
    );

    return true;
  }

  void setError(String message) {
    if (state.isCollected) {
      return;
    }

    state = state.copyWith(
      isConfirming: false,
      errorMessage: message,
    );
  }

  void reset() {
    state = CashCollectionState(
      serviceType: state.serviceType,
    );
  }
}

final cashCollectionProvider = StateNotifierProvider.family<
    CashCollectionNotifier, CashCollectionState, PartnerServiceType>(
  (ref, serviceType) {
    assert(
      serviceType == PartnerServiceType.foodDelivery ||
          serviceType == PartnerServiceType.groceryDelivery,
      'Cash collection supports only Food or Grocery deliveries.',
    );

    return CashCollectionNotifier(
      serviceType,
    );
  },
);
