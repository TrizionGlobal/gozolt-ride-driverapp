import '../../../../core/utils/json_parse.dart';
import 'ride_stop.dart';

class RideDetail {
  final String id;
  final String status;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropoffAddress;
  final double dropoffLat;
  final double dropoffLng;
  final double? baseFare;
  final double? distanceFare;
  final double? timeFare;
  final double? waitTimeFee;
  final double? bookingFee;
  final double? totalFare;
  final double? distanceKm;
  final int? durationMinutes;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? requestedAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<RideStop> stops;
  final double? tipAmount;

  const RideDetail({
    required this.id,
    required this.status,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    this.baseFare,
    this.distanceFare,
    this.timeFare,
    this.waitTimeFee,
    this.bookingFee,
    this.totalFare,
    this.distanceKm,
    this.durationMinutes,
    required this.paymentMethod,
    required this.paymentStatus,
    this.requestedAt,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.stops = const [],
    this.tipAmount,
  });

  factory RideDetail.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'] as Map<String, dynamic>?;

    final tipsList = json['tips'] as List<dynamic>?;
    double? calculatedTip;
    if (tipsList != null && tipsList.isNotEmpty) {
      double sum = 0;
      for (final t in tipsList) {
        if (t is Map<String, dynamic>) {
          sum += toDouble(t['amount']) ?? 0;
        }
      }
      calculatedTip = sum;
    }

    return RideDetail(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      pickupAddress: json['pickupAddress'] as String? ?? json['pickup_address'] as String? ?? '',
      pickupLat: toDouble(json['pickupLat']) ?? toDouble(json['pickup_lat']) ?? 0.0,
      pickupLng: toDouble(json['pickupLng']) ?? toDouble(json['pickup_lng']) ?? 0.0,
      dropoffAddress: json['dropoffAddress'] as String? ?? json['dropoff_address'] as String? ?? '',
      dropoffLat: toDouble(json['dropoffLat']) ?? toDouble(json['dropoff_lat']) ?? 0.0,
      dropoffLng: toDouble(json['dropoffLng']) ?? toDouble(json['dropoff_lng']) ?? 0.0,
      baseFare: toDouble(json['baseFare']) ?? toDouble(json['base_fare']),
      distanceFare: toDouble(json['distanceFare']) ?? toDouble(json['distance_fare']),
      timeFare: toDouble(json['timeFare']) ?? toDouble(json['time_fare']),
      waitTimeFee: toDouble(json['waitTimeFee']) ?? toDouble(json['wait_time_fee']),
      bookingFee: toDouble(json['bookingFee']) ?? toDouble(json['booking_fee']),
      totalFare: toDouble(json['actualFare']) ??
          toDouble(json['actual_fare']) ??
          toDouble(json['estimatedFare']) ??
          toDouble(json['estimated_fare']),
      distanceKm: toDouble(json['distanceKm']) ?? toDouble(json['distance_km']),
      durationMinutes: toInt(json['durationMinutes'] ?? json['duration_minutes']),
      paymentMethod: payment?['method'] as String? ?? json['paymentMethod'] as String? ?? json['payment_method'] as String? ?? 'cash',
      paymentStatus: payment?['status'] as String? ?? 'PENDING',
      requestedAt: _parseDate(json['requestedAt'] ?? json['requested_at']),
      acceptedAt: _parseDate(json['acceptedAt'] ?? json['accepted_at']),
      arrivedAt: _parseDate(json['arrivedAt'] ?? json['arrived_at']),
      startedAt: _parseDate(json['startedAt'] ?? json['started_at']),
      completedAt: _parseDate(json['completedAt'] ?? json['completed_at']),
      stops: (json['stops'] as List<dynamic>?)
              ?.map((s) => RideStop.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      tipAmount: calculatedTip ?? toDouble(json['tipAmount']) ?? toDouble(json['tip_amount']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
