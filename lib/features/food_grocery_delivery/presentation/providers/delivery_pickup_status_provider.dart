import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../domain/models/delivery_pickup_status.dart';

class DeliveryPickupStatusState {
  const DeliveryPickupStatusState({
    required this.serviceType,
    required this.status,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final PartnerServiceType serviceType;
  final DeliveryPickupStatus status;
  final bool isRefreshing;
  final String? errorMessage;

  bool get isFoodDelivery {
    return serviceType == PartnerServiceType.foodDelivery;
  }

  bool get isGroceryDelivery {
    return serviceType == PartnerServiceType.groceryDelivery;
  }

  bool get isReadyForPickup {
    return status.isReadyForPickup;
  }

  String get statusLabel {
    return status.label(
      isFoodDelivery: isFoodDelivery,
    );
  }

  String get statusDescription {
    return status.description(
      isFoodDelivery: isFoodDelivery,
    );
  }

  DeliveryPickupStatusState copyWith({
    DeliveryPickupStatus? status,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeliveryPickupStatusState(
      serviceType: serviceType,
      status: status ?? this.status,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class DeliveryPickupStatusNotifier
    extends StateNotifier<DeliveryPickupStatusState> {
  DeliveryPickupStatusNotifier(
    PartnerServiceType serviceType,
  ) : super(
          DeliveryPickupStatusState(
            serviceType: serviceType,
            status: serviceType == PartnerServiceType.foodDelivery
                ? DeliveryPickupStatus.preparing
                : DeliveryPickupStatus.pickingItems,
          ),
        );

  Future<void> refreshStatus() async {
    if (state.isRefreshing || state.isReadyForPickup) {
      return;
    }

    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
    );

    // TODO(FOOD_GROCERY_API):
    // Replace this temporary delay and status advancement with the
    // restaurant/store preparation-status endpoint or WebSocket event
    await Future<void>.delayed(
      const Duration(milliseconds: 650),
    );

    state = state.copyWith(
      status: _nextTemporaryStatus(),
      isRefreshing: false,
      clearError: true,
    );
  }

  /// Called later by the API or WebSocket integration when the supplier
  /// preparation status changes
  void updateStatusFromApi(
    DeliveryPickupStatus status,
  ) {
    state = state.copyWith(
      status: status,
      isRefreshing: false,
      clearError: true,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      isRefreshing: false,
      errorMessage: message,
    );
  }

  void reset() {
    state = DeliveryPickupStatusState(
      serviceType: state.serviceType,
      status: state.isFoodDelivery
          ? DeliveryPickupStatus.preparing
          : DeliveryPickupStatus.pickingItems,
    );
  }

  DeliveryPickupStatus _nextTemporaryStatus() {
    if (state.isFoodDelivery) {
      switch (state.status) {
        case DeliveryPickupStatus.preparing:
          return DeliveryPickupStatus.packing;

        case DeliveryPickupStatus.pickingItems:
          return DeliveryPickupStatus.packing;

        case DeliveryPickupStatus.packing:
          return DeliveryPickupStatus.readyForPickup;

        case DeliveryPickupStatus.readyForPickup:
          return DeliveryPickupStatus.readyForPickup;
      }
    }

    switch (state.status) {
      case DeliveryPickupStatus.preparing:
        return DeliveryPickupStatus.pickingItems;

      case DeliveryPickupStatus.pickingItems:
        return DeliveryPickupStatus.packing;

      case DeliveryPickupStatus.packing:
        return DeliveryPickupStatus.readyForPickup;

      case DeliveryPickupStatus.readyForPickup:
        return DeliveryPickupStatus.readyForPickup;
    }
  }
}

final deliveryPickupStatusProvider = StateNotifierProvider.family<
    DeliveryPickupStatusNotifier,
    DeliveryPickupStatusState,
    PartnerServiceType>(
  (ref, serviceType) {
    assert(
      serviceType == PartnerServiceType.foodDelivery ||
          serviceType == PartnerServiceType.groceryDelivery,
      'Pickup status supports only Food or Grocery delivery services.',
    );

    return DeliveryPickupStatusNotifier(
      serviceType,
    );
  },
);
