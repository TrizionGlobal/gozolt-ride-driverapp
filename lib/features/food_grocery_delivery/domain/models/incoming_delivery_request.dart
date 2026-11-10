import '../../../partner_services/domain/models/partner_service_type.dart';
import 'delivery_payment_method.dart';

class IncomingDeliveryRequest {
  const IncomingDeliveryRequest({
    required this.requestId,
    required this.deliveryId,
    required this.orderId,
    required this.serviceType,
    required this.businessName,
    required this.pickupArea,
    required this.customerDropArea,
    required this.distanceToPickupKm,
    required this.estimatedDeliveryDistanceKm,
    required this.estimatedMinutes,
    required this.estimatedEarning,
    required this.paymentMethod,
    required this.packageCount,
    this.cashAmountToCollect,
  })  : assert(
          serviceType == PartnerServiceType.foodDelivery ||
              serviceType == PartnerServiceType.groceryDelivery,
          'Incoming request requires Food or Grocery service type.',
        ),
        assert(
          paymentMethod != DeliveryPaymentMethod.cash ||
              cashAmountToCollect != null,
          'Cash delivery requests require an exact collection amount.',
        );

  final String requestId;
  final String deliveryId;
  final String orderId;
  final PartnerServiceType serviceType;
  final String businessName;

  final String pickupArea;
  final String customerDropArea;
  final double distanceToPickupKm;
  final double estimatedDeliveryDistanceKm;
  final int estimatedMinutes;
  final double estimatedEarning;
  final DeliveryPaymentMethod paymentMethod;
  final int packageCount;

  final double? cashAmountToCollect;

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

  String get packageLabel {
    return packageCount == 1 ? '1 package' : '$packageCount packages';
  }
}
