import '../../../../core/utils/json_parse.dart';

class RideSummary {
  final String rideId;
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double totalFare;
  final double driverEarnings;
  final double distanceKm;
  final int durationMinutes;
  final String paymentMethod;
  final double tipAmount;
  final double bookingFee;
  final double surgeMultiplier;

  const RideSummary({
    required this.rideId,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.totalFare,
    required this.driverEarnings,
    required this.distanceKm,
    required this.durationMinutes,
    required this.paymentMethod,
    this.tipAmount = 0.0,
    this.bookingFee = 0.0,
    this.surgeMultiplier = 1.0,
  });

  factory RideSummary.fromJson(Map<String, dynamic> json) {
    return RideSummary(
      rideId: json['rideId'] as String? ?? json['id'] as String? ?? '',
      baseFare: toDouble(json['baseFare']) ?? 0.0,
      distanceFare: toDouble(json['distanceFare']) ?? 0.0,
      timeFare: toDouble(json['timeFare']) ?? 0.0,
      totalFare: toDouble(json['totalFare']) ?? toDouble(json['actualFare']) ?? 0.0,
      driverEarnings: toDouble(json['driverEarnings']) ?? 0.0,
      distanceKm: toDouble(json['distanceKm']) ?? 0.0,
      durationMinutes: toInt(json['durationMinutes']),
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      tipAmount: toDouble(json['tipAmount']) ?? 0.0,
      bookingFee: toDouble(json['bookingFee']) ?? 0.0,
      surgeMultiplier: toDouble(json['surgeMultiplier']) ?? 1.0,
    );
  }
}
