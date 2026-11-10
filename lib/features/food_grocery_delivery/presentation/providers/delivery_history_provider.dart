import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../partner_services/domain/models/partner_service_type.dart';
import '../../domain/models/delivery_history_record.dart';
import '../../domain/models/delivery_job.dart';

class DeliveryHistoryState {
  const DeliveryHistoryState({
    required this.serviceType,
    this.records = const <DeliveryHistoryRecord>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final PartnerServiceType serviceType;
  final List<DeliveryHistoryRecord> records;
  final bool isLoading;
  final String? errorMessage;

  int get completedDeliveries {
    return records.length;
  }

  double get totalDeliveryEarnings {
    return records.fold<double>(
      0,
      (total, record) => total + record.deliveryEarning,
    );
  }

  double get totalCashCollected {
    return records.fold<double>(
      0,
      (total, record) => total + record.cashCollected,
    );
  }

  bool get isEmpty {
    return records.isEmpty;
  }

  DeliveryHistoryState copyWith({
    List<DeliveryHistoryRecord>? records,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeliveryHistoryState(
      serviceType: serviceType,
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class DeliveryHistoryNotifier extends StateNotifier<DeliveryHistoryState> {
  DeliveryHistoryNotifier(
    PartnerServiceType serviceType,
  ) : super(
          DeliveryHistoryState(
            serviceType: serviceType,
          ),
        );

  void recordCompletedDelivery(
    DeliveryJob job,
  ) {
    if (job.serviceType != state.serviceType) {
      state = state.copyWith(
        errorMessage:
            'The completed delivery does not match the selected service.',
      );
      return;
    }

    final alreadyRecorded = state.records.any(
      (record) => record.deliveryId == job.deliveryId,
    );

    if (alreadyRecorded) {
      return;
    }

    final record = DeliveryHistoryRecord(
      deliveryId: job.deliveryId,
      orderId: job.orderId,
      serviceType: job.serviceType,
      businessName: job.businessName,
      customerName: job.customerName,
      paymentMethod: job.paymentMethod,
      deliveryEarning: job.estimatedEarning,
      cashCollected: job.paymentMethod.requiresCashCollection
          ? job.cashAmountToCollect ?? 0
          : 0,
      completedAt: DateTime.now(),
    );

    state = state.copyWith(
      records: List<DeliveryHistoryRecord>.unmodifiable(
        <DeliveryHistoryRecord>[
          record,
          ...state.records,
        ],
      ),
      clearError: true,
    );

    // TODO(FOOD_GROCERY_API):
    // Replace this local record with completed delivery history
    // returned by the backend.
  }

  void replaceRecords(
    List<DeliveryHistoryRecord> records,
  ) {
    final matchingRecords = records
        .where(
          (record) => record.serviceType == state.serviceType,
        )
        .toList(growable: false);

    state = state.copyWith(
      records: List<DeliveryHistoryRecord>.unmodifiable(
        matchingRecords,
      ),
      isLoading: false,
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

final deliveryHistoryProvider = StateNotifierProvider.family<
    DeliveryHistoryNotifier, DeliveryHistoryState, PartnerServiceType>(
  (ref, serviceType) {
    assert(
      serviceType == PartnerServiceType.foodDelivery ||
          serviceType == PartnerServiceType.groceryDelivery,
      'Delivery history supports only Food or Grocery services.',
    );

    return DeliveryHistoryNotifier(
      serviceType,
    );
  },
);
