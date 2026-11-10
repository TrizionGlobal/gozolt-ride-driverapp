import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/partner_service_type.dart';

class PartnerAvailabilityState {
  const PartnerAvailabilityState({
    this.allServicesOnline = false,
    this.onlineServices = const <PartnerServiceType>{},
    this.isUpdating = false,
    this.activeService,
    this.activeWorkId,
    this.errorMessage,
  });

  final bool allServicesOnline;
  final Set<PartnerServiceType> onlineServices;
  final bool isUpdating;

  final PartnerServiceType? activeService;
  final String? activeWorkId;

  final String? errorMessage;

  bool get isBusy {
    return activeService != null &&
        activeWorkId != null &&
        activeWorkId!.trim().isNotEmpty;
  }

  bool get showIndividualAvailabilityControls {
    return !allServicesOnline;
  }

  bool isServiceOnline(
    PartnerServiceType service,
  ) {
    return onlineServices.contains(service);
  }

  bool canReceiveRequestsFor(
    PartnerServiceType service,
  ) {
    return !isBusy && isServiceOnline(service);
  }

  PartnerAvailabilityState copyWith({
    bool? allServicesOnline,
    Set<PartnerServiceType>? onlineServices,
    bool? isUpdating,
    PartnerServiceType? activeService,
    String? activeWorkId,
    bool clearActiveWork = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PartnerAvailabilityState(
      allServicesOnline: allServicesOnline ?? this.allServicesOnline,
      onlineServices: onlineServices ?? this.onlineServices,
      isUpdating: isUpdating ?? this.isUpdating,
      activeService:
          clearActiveWork ? null : activeService ?? this.activeService,
      activeWorkId: clearActiveWork ? null : activeWorkId ?? this.activeWorkId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PartnerAvailabilityNotifier
    extends StateNotifier<PartnerAvailabilityState> {
  PartnerAvailabilityNotifier()
      : super(
          const PartnerAvailabilityState(),
        );

  Future<bool> setAllServicesOnline({
    required bool value,
    required Set<PartnerServiceType> approvedServices,
  }) async {
    if (state.isUpdating) {
      return false;
    }

    if (state.isBusy) {
      state = state.copyWith(
        errorMessage: 'Complete the active job before changing availability.',
      );
      return false;
    }

    state = state.copyWith(
      isUpdating: true,
      clearError: true,
    );

    // TODO(PARTNER_AVAILABILITY_API):
    // Replace this delay with the unified partner-availability endpoint.
    await Future<void>.delayed(
      const Duration(milliseconds: 400),
    );

    state = state.copyWith(
      allServicesOnline: value,
      onlineServices: Set<PartnerServiceType>.unmodifiable(
        value ? approvedServices : const <PartnerServiceType>{},
      ),
      isUpdating: false,
      clearError: true,
    );

    return true;
  }

  Future<bool> setServiceOnline({
    required PartnerServiceType service,
    required bool value,
    required Set<PartnerServiceType> approvedServices,
  }) async {
    if (state.isUpdating) {
      return false;
    }

    if (state.allServicesOnline) {
      state = state.copyWith(
        errorMessage:
            'Turn off All Services mode to manage services individually.',
      );
      return false;
    }

    if (!approvedServices.contains(service)) {
      state = state.copyWith(
        errorMessage: 'This service is not approved for your account.',
      );
      return false;
    }

    if (state.isBusy) {
      state = state.copyWith(
        errorMessage: 'Complete the active job before changing availability.',
      );
      return false;
    }

    state = state.copyWith(
      isUpdating: true,
      clearError: true,
    );

    // TODO(PARTNER_AVAILABILITY_API):
    // Replace this delay with the service availability endpoint.
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    final updatedServices = Set<PartnerServiceType>.from(state.onlineServices);

    if (value) {
      updatedServices.add(service);
    } else {
      updatedServices.remove(service);
    }

    state = state.copyWith(
      onlineServices: Set<PartnerServiceType>.unmodifiable(
        updatedServices,
      ),
      isUpdating: false,
      clearError: true,
    );

    return true;
  }

  bool beginActiveWork({
    required PartnerServiceType service,
    required String workId,
  }) {
    final normalizedWorkId = workId.trim();

    if (normalizedWorkId.isEmpty) {
      state = state.copyWith(
        errorMessage: 'A valid job reference is required.',
      );
      return false;
    }

    if (!state.isServiceOnline(service)) {
      state = state.copyWith(
        errorMessage: 'Go online for this service before accepting requests.',
      );
      return false;
    }

    if (state.isBusy) {
      final sameWork = state.activeService == service &&
          state.activeWorkId == normalizedWorkId;

      if (sameWork) {
        return true;
      }

      state = state.copyWith(
        errorMessage:
            'Complete the current job before accepting another request.',
      );
      return false;
    }

    state = state.copyWith(
      activeService: service,
      activeWorkId: normalizedWorkId,
      clearError: true,
    );

    return true;
  }

  void completeActiveWork({
    required PartnerServiceType service,
    required String workId,
  }) {
    if (state.activeService != service || state.activeWorkId != workId.trim()) {
      return;
    }

    state = state.copyWith(
      clearActiveWork: true,
      clearError: true,
    );
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }

  void reset() {
    state = const PartnerAvailabilityState();
  }
}

final partnerAvailabilityProvider = StateNotifierProvider<
    PartnerAvailabilityNotifier, PartnerAvailabilityState>(
  (ref) {
    return PartnerAvailabilityNotifier();
  },
);
