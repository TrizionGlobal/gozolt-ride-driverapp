import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/partner_service_type.dart';

class PartnerServiceState {
  const PartnerServiceState({
    this.approvedServices = const {},
    this.selectedService,
    this.isLoading = false,
    this.errorMessage,
  });

  final Set<PartnerServiceType> approvedServices;
  final PartnerServiceType? selectedService;
  final bool isLoading;
  final String? errorMessage;

  bool isApproved(PartnerServiceType service) {
    return approvedServices.contains(service);
  }

  PartnerServiceState copyWith({
    Set<PartnerServiceType>? approvedServices,
    PartnerServiceType? selectedService,
    bool clearSelectedService = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PartnerServiceState(
      approvedServices: approvedServices ?? this.approvedServices,
      selectedService:
          clearSelectedService ? null : selectedService ?? this.selectedService,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PartnerServiceNotifier extends StateNotifier<PartnerServiceState> {
  PartnerServiceNotifier()
      : super(
          const PartnerServiceState(
            // TODO(FOOD_GROCERY_API):
            // Replace these temporary approvals with services returned
            // by the authenticated partner-profile API.
            approvedServices: {
              PartnerServiceType.cabBooking,
              PartnerServiceType.foodDelivery,
              PartnerServiceType.groceryDelivery,
            },
          ),
        );

  bool selectService(PartnerServiceType service) {
    if (!state.isApproved(service)) {
      state = state.copyWith(
        errorMessage: 'This service is not approved for your account.',
      );
      return false;
    }

    state = state.copyWith(
      selectedService: service,
      clearError: true,
    );

    return true;
  }

  void clearSelection() {
    state = state.copyWith(
      clearSelectedService: true,
      clearError: true,
    );
  }

  void setApprovedServices(
    Set<PartnerServiceType> approvedServices,
  ) {
    final selectedService = state.selectedService;

    state = PartnerServiceState(
      approvedServices: approvedServices,
      selectedService:
          selectedService != null && approvedServices.contains(selectedService)
              ? selectedService
              : null,
    );
  }
}

final partnerServiceProvider =
    StateNotifierProvider<PartnerServiceNotifier, PartnerServiceState>(
  (ref) {
    return PartnerServiceNotifier();
  },
);
