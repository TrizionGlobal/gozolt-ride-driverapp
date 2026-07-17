import '../../../../core/utils/json_parse.dart';
import 'ride_status.dart';
import 'ride_stop.dart';
import 'rider_info.dart';

class Ride {
  final String id;
  final RideStatus status;
  final RiderInfo rider;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropoffAddress;
  final double dropoffLat;
  final double dropoffLng;
  final double fare;
  final double distanceKm;
  final int estimatedMinutes;
  final String? otp;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<RideStop> stops;
  final int currentStopIndex;

  const Ride({
    required this.id,
    required this.status,
    required this.rider,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.fare,
    required this.distanceKm,
    required this.estimatedMinutes,
    this.otp,
    this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
    this.stops = const [],
    this.currentStopIndex = 0,
  });

  bool get hasStops => stops.isNotEmpty;

  bool get isOnLastStop =>
      !hasStops || currentStopIndex >= stops.length;

  RideStop? get currentStop =>
      hasStops && currentStopIndex < stops.length
          ? stops[currentStopIndex]
          : null;

  List<RideStop> get remainingStops =>
      hasStops ? stops.sublist(currentStopIndex) : [];

  Ride copyWith({
    RideStatus? status,
    String? otp,
    String? dropoffAddress,
    double? dropoffLat,
    double? dropoffLng,
    double? fare,
    String? paymentMethod,
    List<RideStop>? stops,
    int? currentStopIndex,
  }) {
    return Ride(
      id: id,
      status: status ?? this.status,
      rider: rider,
      pickupAddress: pickupAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      fare: fare ?? this.fare,
      distanceKm: distanceKm,
      estimatedMinutes: estimatedMinutes,
      otp: otp ?? this.otp,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt,
      updatedAt: updatedAt,
      stops: stops ?? this.stops,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
    );
  }

  factory Ride.fromJson(Map<String, dynamic> json) {
    final riderJson = json['user'] as Map<String, dynamic>? ??
        json['rider'] as Map<String, dynamic>? ??
        {};

    return Ride(
      id: json['id'] as String? ?? '',
      status: RideStatus.fromString(json['status'] as String? ?? ''),
      rider: RiderInfo.fromJson(riderJson),
      pickupAddress: json['pickupAddress'] as String? ?? '',
      pickupLat: toDouble(json['pickupLat']) ?? 0.0,
      pickupLng: toDouble(json['pickupLng']) ?? 0.0,
      dropoffAddress: json['dropoffAddress'] as String? ?? '',
      dropoffLat: toDouble(json['dropoffLat']) ?? 0.0,
      dropoffLng: toDouble(json['dropoffLng']) ?? 0.0,
      fare: toDouble(json['actualFare']) ??
          toDouble(json['estimatedFare']) ??
          toDouble(json['fare']) ??
          0.0,
      distanceKm: toDouble(json['distanceKm']) ?? toDouble(json['estimatedDistance']) ?? 0.0,
      estimatedMinutes: toInt(json['estimatedMinutes'] ?? json['durationMinutes']),
      otp: json['otp'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'] as String) 
          : null,
      stops: (json['stops'] as List<dynamic>?)
              ?.map((s) => RideStop.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      currentStopIndex: toInt(json['currentStopIndex']),
    );
  }
}
