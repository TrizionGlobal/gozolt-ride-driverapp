import '../../../partner_services/domain/models/partner_service_type.dart';
import 'delivery_job_stage.dart';

/// Compact representation of the partner's current active delivery.
class ActiveDeliverySummary {
  const ActiveDeliverySummary({
    required this.deliveryId,
    required this.orderId,
    required this.serviceType,
    required this.businessName,
    required this.stage,
  }) : assert(
          serviceType == PartnerServiceType.foodDelivery ||
              serviceType == PartnerServiceType.groceryDelivery,
          'An active delivery requires Food or Grocery service type.',
        );

  final String deliveryId;
  final String orderId;
  final PartnerServiceType serviceType;
  final String businessName;
  final DeliveryJobStage stage;

  String get businessTypeLabel {
    return serviceType == PartnerServiceType.foodDelivery
        ? 'Restaurant'
        : 'Store';
  }
}
