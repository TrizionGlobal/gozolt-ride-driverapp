import '../../../partner_services/domain/models/partner_service_type.dart';
import 'delivery_payment_method.dart';

class DeliveryHistoryRecord {
  const DeliveryHistoryRecord({
    required this.deliveryId,
    required this.orderId,
    required this.serviceType,
    required this.businessName,
    required this.customerName,
    required this.paymentMethod,
    required this.deliveryEarning,
    required this.completedAt,
    this.cashCollected = 0,
  }) : assert(
          serviceType == PartnerServiceType.foodDelivery ||
              serviceType == PartnerServiceType.groceryDelivery,
          'Delivery history supports only Food or Grocery deliveries.',
        );

  final String deliveryId;
  final String orderId;
  final PartnerServiceType serviceType;
  final String businessName;
  final String customerName;
  final DeliveryPaymentMethod paymentMethod;
  final double deliveryEarning;
  final double cashCollected;
  final DateTime completedAt;

  bool get isFoodDelivery {
    return serviceType == PartnerServiceType.foodDelivery;
  }

  bool get isGroceryDelivery {
    return serviceType == PartnerServiceType.groceryDelivery;
  }

  bool get wasCashPayment {
    return paymentMethod.requiresCashCollection;
  }

  String get deliveryTypeLabel {
    return isFoodDelivery ? 'Food Delivery' : 'Grocery Delivery';
  }

  String get businessTypeLabel {
    return isFoodDelivery ? 'Restaurant' : 'Store';
  }

  String get paymentMethodLabel {
    return paymentMethod.displayName;
  }
}
