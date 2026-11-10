import '../../../partner_services/domain/models/partner_service_type.dart';
import 'delivery_job_stage.dart';
import 'delivery_payment_method.dart';

class DeliveryJob {
  const DeliveryJob({
    required this.deliveryId,
    required this.orderId,
    required this.serviceType,
    required this.businessName,
    required this.pickupAddress,
    required this.customerName,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.packageCount,
    required this.estimatedEarning,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.stage,
    this.businessPhone,
    this.customerPhone,
    this.deliveryInstructions,
    this.specialHandlingNote,
    this.cashAmountToCollect,
  })  : assert(
          serviceType == PartnerServiceType.foodDelivery ||
              serviceType == PartnerServiceType.groceryDelivery,
          'DeliveryJob requires Food or Grocery service type.',
        ),
        assert(
          paymentMethod != DeliveryPaymentMethod.cash ||
              cashAmountToCollect != null,
          'Cash deliveries require an exact collection amount.',
        );

  final String deliveryId;
  final String orderId;
  final PartnerServiceType serviceType;

  final String businessName;
  final String pickupAddress;
  final String? businessPhone;

  final String customerName;
  final String? customerPhone;
  final String deliveryAddress;
  final String? deliveryInstructions;

  final DeliveryPaymentMethod paymentMethod;
  final double? cashAmountToCollect;

  final int packageCount;
  final String? specialHandlingNote;
  final double estimatedEarning;

  final double pickupLatitude;
  final double pickupLongitude;
  final double deliveryLatitude;
  final double deliveryLongitude;

  final DeliveryJobStage stage;

  bool get isFoodDelivery {
    return serviceType == PartnerServiceType.foodDelivery;
  }

  bool get isGroceryDelivery {
    return serviceType == PartnerServiceType.groceryDelivery;
  }

  String get deliveryTypeLabel {
    return isFoodDelivery ? 'Food Delivery' : 'Grocery Delivery';
  }

  String get businessTypeLabel {
    return isFoodDelivery ? 'Restaurant' : 'Store';
  }

  String get pickupActionLabel {
    return isFoodDelivery ? 'Navigate to restaurant' : 'Navigate to store';
  }

  String get packageLabel {
    return packageCount == 1 ? '1 package' : '$packageCount packages';
  }

  DeliveryJob copyWith({
    DeliveryJobStage? stage,
    String? deliveryInstructions,
    String? specialHandlingNote,
  }) {
    return DeliveryJob(
      deliveryId: deliveryId,
      orderId: orderId,
      serviceType: serviceType,
      businessName: businessName,
      pickupAddress: pickupAddress,
      businessPhone: businessPhone,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      paymentMethod: paymentMethod,
      cashAmountToCollect: cashAmountToCollect,
      packageCount: packageCount,
      specialHandlingNote: specialHandlingNote ?? this.specialHandlingNote,
      estimatedEarning: estimatedEarning,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      stage: stage ?? this.stage,
    );
  }
}
