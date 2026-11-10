import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../../partner_services/presentation/providers/partner_availability_provider.dart';
import '../../domain/models/active_delivery_summary.dart';
import '../../domain/models/delivery_job_stage.dart';
import '../../domain/models/delivery_payment_method.dart';
import '../../domain/models/incoming_delivery_request.dart';
import 'food_grocery_delivery_home_provider.dart';
import '../../domain/models/delivery_job.dart';
import 'food_grocery_delivery_session_provider.dart';

enum DeliveryRequestOutcome {
  pending,
  accepted,
  declined,
  expired,
  unavailable,
}

class IncomingDeliveryRequestState {
  const IncomingDeliveryRequestState({
    this.request,
    this.secondsRemaining = 0,
    this.isResponding = false,
    this.outcome = DeliveryRequestOutcome.pending,
    this.errorMessage,
  });

  final IncomingDeliveryRequest? request;
  final int secondsRemaining;
  final bool isResponding;
  final DeliveryRequestOutcome outcome;
  final String? errorMessage;

  bool get isAvailable {
    return request != null &&
        secondsRemaining > 0 &&
        outcome == DeliveryRequestOutcome.pending;
  }

  double get countdownProgress {
    const totalSeconds = 45;

    if (secondsRemaining <= 0) {
      return 0;
    }

    return (secondsRemaining / totalSeconds).clamp(
      0.0,
      1.0,
    );
  }

  IncomingDeliveryRequestState copyWith({
    IncomingDeliveryRequest? request,
    bool clearRequest = false,
    int? secondsRemaining,
    bool? isResponding,
    DeliveryRequestOutcome? outcome,
    String? errorMessage,
    bool clearError = false,
  }) {
    return IncomingDeliveryRequestState(
      request: clearRequest ? null : request ?? this.request,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isResponding: isResponding ?? this.isResponding,
      outcome: outcome ?? this.outcome,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class IncomingDeliveryRequestNotifier
    extends StateNotifier<IncomingDeliveryRequestState> {
  IncomingDeliveryRequestNotifier({
    required this.serviceType,
    required this.onAccepted,
    required this.canAcceptRequest,
    required this.beginActiveWork,
  }) : super(const IncomingDeliveryRequestState()) {
    if (canAcceptRequest()) {
      loadTemporaryRequest();
    } else {
      state = const IncomingDeliveryRequestState(
        outcome: DeliveryRequestOutcome.unavailable,
        errorMessage:
            'Go online for this service and complete any active job before receiving another request.',
      );
    }
  }

  final PartnerServiceType serviceType;
  final ValueChanged<DeliveryJob> onAccepted;
  final bool Function() canAcceptRequest;
  final bool Function(String workId) beginActiveWork;

  Timer? _countdownTimer;

  void loadTemporaryRequest() {
    _countdownTimer?.cancel();

    state = IncomingDeliveryRequestState(
      request: _temporaryRequestFor(serviceType),
      secondsRemaining: 45,
    );

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (state.outcome != DeliveryRequestOutcome.pending) {
          timer.cancel();
          return;
        }

        if (state.secondsRemaining <= 1) {
          timer.cancel();

          state = state.copyWith(
            secondsRemaining: 0,
            isResponding: false,
            outcome: DeliveryRequestOutcome.expired,
            errorMessage: 'This delivery request has expired.',
          );
          return;
        }

        state = state.copyWith(
          secondsRemaining: state.secondsRemaining - 1,
        );
      },
    );
  }

  Future<bool> acceptRequest() async {
    final request = state.request;

    if (!canAcceptRequest()) {
      state = state.copyWith(
        isResponding: false,
        outcome: DeliveryRequestOutcome.unavailable,
        errorMessage:
            'You must be online and have no other active job to accept this request.',
      );
      return false;
    }

    if (request == null || !state.isAvailable) {
      state = state.copyWith(
        isResponding: false,
        errorMessage: 'This delivery is no longer available.',
      );
      return false;
    }

    state = state.copyWith(
      isResponding: true,
      clearError: true,
    );

    // TODO(FOOD_GROCERY_API):
    // Replace this delay with the accept-delivery endpoint
    await Future<void>.delayed(
      const Duration(milliseconds: 650),
    );

    if (!state.isAvailable) {
      state = state.copyWith(
        isResponding: false,
        errorMessage: 'This delivery is no longer available.',
      );
      return false;
    }

    _countdownTimer?.cancel();
    final deliveryJob = _temporaryJobFor(request);

    final workStarted = beginActiveWork(
      deliveryJob.deliveryId,
    );

    if (!workStarted) {
      state = state.copyWith(
        isResponding: false,
        outcome: DeliveryRequestOutcome.unavailable,
        errorMessage:
            'Another active job is already in progress. Complete it before accepting this delivery.',
      );
      return false;
    }

    onAccepted(deliveryJob);

    state = state.copyWith(
      secondsRemaining: 0,
      isResponding: false,
      outcome: DeliveryRequestOutcome.accepted,
      clearError: true,
    );

    return true;
  }

  DeliveryJob _temporaryJobFor(
    IncomingDeliveryRequest request,
  ) {
    if (request.isFoodDelivery) {
      return DeliveryJob(
        deliveryId: request.deliveryId,
        orderId: request.orderId,
        serviceType: request.serviceType,
        businessName: request.businessName,
        pickupAddress: '12 The Strand, Sliema, Malta',
        businessPhone: '+356 2123 4567',
        customerName: 'Justin Camilleri',
        customerPhone: '+356 7900 1122',
        deliveryAddress: 'Apartment 8, Triq ix-Xatt, Gzira, Malta',
        deliveryInstructions: 'Use the rear entrance and call on arrival.',
        paymentMethod: request.paymentMethod,
        cashAmountToCollect: request.cashAmountToCollect,
        packageCount: request.packageCount,
        specialHandlingNote: 'Keep the food upright during delivery.',
        estimatedEarning: request.estimatedEarning,
        pickupLatitude: 35.9122,
        pickupLongitude: 14.5034,
        deliveryLatitude: 35.9059,
        deliveryLongitude: 14.4881,
        stage: DeliveryJobStage.accepted,
      );
    }

    return DeliveryJob(
      deliveryId: request.deliveryId,
      orderId: request.orderId,
      serviceType: request.serviceType,
      businessName: request.businessName,
      pickupAddress: 'Tower Road, Sliema, Malta',
      businessPhone: '+356 2134 5678',
      customerName: 'Justin Camilleri',
      customerPhone: '+356 7900 1122',
      deliveryAddress: "Flat 4, Triq San Gorg, St Julian's, Malta",
      deliveryInstructions: 'Please call on arrival. Lift is available.',
      paymentMethod: request.paymentMethod,
      cashAmountToCollect: request.cashAmountToCollect,
      packageCount: request.packageCount,
      specialHandlingNote: 'Handle chilled and fragile items carefully.',
      estimatedEarning: request.estimatedEarning,
      pickupLatitude: 35.9107,
      pickupLongitude: 14.5026,
      deliveryLatitude: 35.9180,
      deliveryLongitude: 14.4890,
      stage: DeliveryJobStage.accepted,
    );
  }

  void declineRequest() {
    if (state.isResponding || state.outcome != DeliveryRequestOutcome.pending) {
      return;
    }

    _countdownTimer?.cancel();

    // TODO(FOOD_GROCERY_API):
    // Notify the backend that the partner declined the request
    state = state.copyWith(
      secondsRemaining: 0,
      outcome: DeliveryRequestOutcome.declined,
      clearError: true,
    );
  }

  void markRequestUnavailable() {
    _countdownTimer?.cancel();

    state = state.copyWith(
      secondsRemaining: 0,
      isResponding: false,
      outcome: DeliveryRequestOutcome.unavailable,
      errorMessage: 'This delivery is no longer available.',
    );
  }

  IncomingDeliveryRequest _temporaryRequestFor(
    PartnerServiceType type,
  ) {
    if (type == PartnerServiceType.foodDelivery) {
      return const IncomingDeliveryRequest(
        requestId: 'REQ-FOOD-10241',
        deliveryId: 'DEL-FOOD-10241',
        orderId: 'GOF-10241',
        serviceType: PartnerServiceType.foodDelivery,
        businessName: 'Harbour Pizza',
        pickupArea: 'Sliema',
        customerDropArea: 'Gżira',
        distanceToPickupKm: 1.2,
        estimatedDeliveryDistanceKm: 3.4,
        estimatedMinutes: 25,
        estimatedEarning: 5.20,
        paymentMethod: DeliveryPaymentMethod.cash,
        packageCount: 2,
        cashAmountToCollect: 42.00,
      );
    }

    return const IncomingDeliveryRequest(
      requestId: 'REQ-GROCERY-20518',
      deliveryId: 'DEL-GROCERY-20518',
      orderId: 'GOG-20518',
      serviceType: PartnerServiceType.groceryDelivery,
      businessName: 'FreshMart Sliema',
      pickupArea: 'Sliema',
      customerDropArea: 'St Julian’s',
      distanceToPickupKm: 1.8,
      estimatedDeliveryDistanceKm: 4.1,
      estimatedMinutes: 30,
      estimatedEarning: 6.10,
      paymentMethod: DeliveryPaymentMethod.card,
      packageCount: 3,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

final incomingDeliveryRequestProvider = StateNotifierProvider.autoDispose
    .family<IncomingDeliveryRequestNotifier, IncomingDeliveryRequestState,
        PartnerServiceType>(
  (ref, serviceType) {
    return IncomingDeliveryRequestNotifier(
      serviceType: serviceType,
      canAcceptRequest: () {
        return ref
            .read(
              partnerAvailabilityProvider,
            )
            .canReceiveRequestsFor(serviceType);
      },
      beginActiveWork: (workId) {
        return ref
            .read(
              partnerAvailabilityProvider.notifier,
            )
            .beginActiveWork(
              service: serviceType,
              workId: workId,
            );
      },
      onAccepted: (deliveryJob) {
        ref
            .read(
              foodGroceryDeliverySessionProvider(
                serviceType,
              ).notifier,
            )
            .setActiveJob(deliveryJob);
        ref
            .read(
              foodGroceryDeliveryHomeProvider(
                serviceType,
              ).notifier,
            )
            .setActiveDelivery(
              ActiveDeliverySummary(
                deliveryId: deliveryJob.deliveryId,
                orderId: deliveryJob.orderId,
                serviceType: deliveryJob.serviceType,
                businessName: deliveryJob.businessName,
                stage: deliveryJob.stage,
              ),
            );
      },
    );
  },
);
