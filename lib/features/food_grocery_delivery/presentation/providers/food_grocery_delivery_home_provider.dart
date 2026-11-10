import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../domain/models/active_delivery_summary.dart';
import '../../domain/models/delivery_today_summary.dart';
import '../../domain/models/delivery_job_stage.dart';

class FoodGroceryDeliveryHomeState {
  const FoodGroceryDeliveryHomeState({
    required this.serviceType,
    this.isOnline = false,
    this.isUpdatingAvailability = false,
    this.activeDelivery,
    this.todaySummary = DeliveryTodaySummary.empty,
    this.errorMessage,
  });

  final PartnerServiceType serviceType;
  final bool isOnline;
  final bool isUpdatingAvailability;
  final ActiveDeliverySummary? activeDelivery;
  final DeliveryTodaySummary todaySummary;
  final String? errorMessage;

  bool get hasActiveDelivery {
    return activeDelivery != null && !activeDelivery!.stage.isTerminal;
  }

  FoodGroceryDeliveryHomeState copyWith({
    bool? isOnline,
    bool? isUpdatingAvailability,
    ActiveDeliverySummary? activeDelivery,
    bool clearActiveDelivery = false,
    DeliveryTodaySummary? todaySummary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FoodGroceryDeliveryHomeState(
      serviceType: serviceType,
      isOnline: isOnline ?? this.isOnline,
      isUpdatingAvailability:
          isUpdatingAvailability ?? this.isUpdatingAvailability,
      activeDelivery:
          clearActiveDelivery ? null : activeDelivery ?? this.activeDelivery,
      todaySummary: todaySummary ?? this.todaySummary,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class FoodGroceryDeliveryHomeNotifier
    extends StateNotifier<FoodGroceryDeliveryHomeState> {
  FoodGroceryDeliveryHomeNotifier(
    PartnerServiceType serviceType,
  ) : super(
          FoodGroceryDeliveryHomeState(
            serviceType: serviceType,

            // TODO(FOOD_GROCERY_API):
            // Replace these demonstration values with today's server summary
            todaySummary: const DeliveryTodaySummary(
              completedDeliveries: 3,
              deliveryEarnings: 14.50,
              pendingEarnings: 9.20,
              cashCollected: 42.00,
            ),
          ),
        );
  final Set<String> _recordedCompletedDeliveryIds = <String>{};
  Future<void> setOnline(bool value) async {
    if (state.isUpdatingAvailability || state.isOnline == value) {
      return;
    }

    state = state.copyWith(
      isUpdatingAvailability: true,
      clearError: true,
    );

    // TODO(FOOD_GROCERY_API):
    // Call the Food/Grocery delivery availability endpoint here
    await Future<void>.delayed(
      const Duration(milliseconds: 450),
    );

    state = state.copyWith(
      isOnline: value,
      isUpdatingAvailability: false,
      clearError: true,
    );
  }

  Future<void> toggleAvailability() async {
    await setOnline(!state.isOnline);
  }

  void setActiveDelivery(
    ActiveDeliverySummary activeDelivery,
  ) {
    state = state.copyWith(
      activeDelivery: activeDelivery,
      clearError: true,
    );
  }

  void updateActiveDeliveryStage(
    DeliveryJobStage stage,
  ) {
    final activeDelivery = state.activeDelivery;

    if (activeDelivery == null) {
      return;
    }

    state = state.copyWith(
      activeDelivery: ActiveDeliverySummary(
        deliveryId: activeDelivery.deliveryId,
        orderId: activeDelivery.orderId,
        serviceType: activeDelivery.serviceType,
        businessName: activeDelivery.businessName,
        stage: stage,
      ),
      clearError: true,
    );
  }

  void recordCompletedDelivery({
    required String deliveryId,
    required double deliveryEarning,
    double cashCollected = 0,
  }) {
    final normalizedDeliveryId = deliveryId.trim();

    if (normalizedDeliveryId.isEmpty ||
        _recordedCompletedDeliveryIds.contains(normalizedDeliveryId)) {
      return;
    }

    _recordedCompletedDeliveryIds.add(normalizedDeliveryId);

    final currentSummary = state.todaySummary;

    state = state.copyWith(
      todaySummary: DeliveryTodaySummary(
        completedDeliveries: currentSummary.completedDeliveries + 1,
        deliveryEarnings: currentSummary.deliveryEarnings + deliveryEarning,
        pendingEarnings: currentSummary.pendingEarnings + deliveryEarning,
        cashCollected: currentSummary.cashCollected + cashCollected,
      ),
      clearError: true,
    );

    // TODO(FOOD_GROCERY_API):
    // Replace this local update with the completed-delivery response
    // and the latest server-provided daily summary.
  }

  void clearActiveDelivery() {
    state = state.copyWith(
      clearActiveDelivery: true,
      clearError: true,
    );
  }

  void updateTodaySummary(
    DeliveryTodaySummary summary,
  ) {
    state = state.copyWith(
      todaySummary: summary,
      clearError: true,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      isUpdatingAvailability: false,
      errorMessage: message,
    );
  }
}

final foodGroceryDeliveryHomeProvider = StateNotifierProvider.family<
    FoodGroceryDeliveryHomeNotifier,
    FoodGroceryDeliveryHomeState,
    PartnerServiceType>(
  (ref, serviceType) {
    assert(
      serviceType == PartnerServiceType.foodDelivery ||
          serviceType == PartnerServiceType.groceryDelivery,
      'Delivery Home supports only Food or Grocery service types.',
    );

    return FoodGroceryDeliveryHomeNotifier(serviceType);
  },
);
