import '../../../../core/utils/json_parse.dart';

class RideHistoryItem {
  final String id;
  final String status;
  final String pickupAddress;
  final String dropoffAddress;
  final String paymentMethod;
  final double? fare;
  final double? tipAmount;
  final DateTime? completedAt;
  final DateTime createdAt;

  const RideHistoryItem({
    required this.id,
    required this.status,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.paymentMethod,
    this.fare,
    this.tipAmount,
    this.completedAt,
    required this.createdAt,
  });

  factory RideHistoryItem.fromJson(Map<String, dynamic> json) {
    return RideHistoryItem(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      pickupAddress: json['pickupAddress'] as String? ?? json['pickup_address'] as String? ?? '',
      dropoffAddress: json['dropoffAddress'] as String? ?? json['dropoff_address'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? json['payment_method'] as String? ?? 'cash',
      fare: toDouble(json['actualFare']) ?? toDouble(json['actual_fare']),
      tipAmount: toDouble(json['tipAmount']) ?? toDouble(json['tip_amount']),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : json['completed_at'] != null
              ? DateTime.tryParse(json['completed_at'] as String)
              : null,
      createdAt: DateTime.tryParse(
              json['createdAt'] as String? ?? json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
