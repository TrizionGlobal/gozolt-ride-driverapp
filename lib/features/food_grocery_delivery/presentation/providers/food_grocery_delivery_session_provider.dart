import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../domain/models/delivery_job.dart';
import '../../domain/models/delivery_job_stage.dart';

class FoodGroceryDeliverySessionState {
  const FoodGroceryDeliverySessionState({
    required this.serviceType,
    this.activeJob,
    this.isLoading = false,
    this.errorMessage,
  });

  final PartnerServiceType serviceType;
  final DeliveryJob? activeJob;
  final bool isLoading;
  final String? errorMessage;

  bool get hasActiveJob {
    return activeJob != null && !activeJob!.stage.isTerminal;
  }

  FoodGroceryDeliverySessionState copyWith({
    DeliveryJob? activeJob,
    bool clearActiveJob = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FoodGroceryDeliverySessionState(
      serviceType: serviceType,
      activeJob: clearActiveJob ? null : activeJob ?? this.activeJob,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class FoodGroceryDeliverySessionNotifier
    extends StateNotifier<FoodGroceryDeliverySessionState> {
  FoodGroceryDeliverySessionNotifier(
    PartnerServiceType serviceType,
  ) : super(
          FoodGroceryDeliverySessionState(
            serviceType: serviceType,
          ),
        );

  void setActiveJob(DeliveryJob job) {
    if (job.serviceType != state.serviceType) {
      state = state.copyWith(
        errorMessage:
            'The delivery service does not match the selected service.',
      );
      return;
    }

    state = state.copyWith(
      activeJob: job,
      clearError: true,
    );
  }

  void updateStage(DeliveryJobStage stage) {
    final job = state.activeJob;

    if (job == null) {
      state = state.copyWith(
        errorMessage: 'No active delivery was found.',
      );
      return;
    }

    state = state.copyWith(
      activeJob: job.copyWith(stage: stage),
      clearError: true,
    );
  }

  void clearActiveJob() {
    state = state.copyWith(
      clearActiveJob: true,
      clearError: true,
    );
  }

  void setLoading(bool value) {
    state = state.copyWith(
      isLoading: value,
      clearError: value,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: message,
    );
  }
}

final foodGroceryDeliverySessionProvider = StateNotifierProvider.family<
    FoodGroceryDeliverySessionNotifier,
    FoodGroceryDeliverySessionState,
    PartnerServiceType>(
  (ref, serviceType) {
    assert(
      serviceType == PartnerServiceType.foodDelivery ||
          serviceType == PartnerServiceType.groceryDelivery,
      'Delivery sessions support only Food or Grocery service types.',
    );

    return FoodGroceryDeliverySessionNotifier(
      serviceType,
    );
  },
);
