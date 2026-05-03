import '../../../../core/utils/json_parse.dart';

class DriverVehicle {
  final String id;
  final String make;
  final String model;
  final String plate;
  final String type;

  const DriverVehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.plate,
    required this.type,
  });

  factory DriverVehicle.fromJson(Map<String, dynamic> json) {
    return DriverVehicle(
      id: json['id'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      plate: json['plateNumber'] as String? ?? json['plate'] as String? ?? '',
      type: json['vehicleType'] as String? ?? json['type'] as String? ?? 'standard',
    );
  }
}

class DriverProfile {
  final String id;
  final String driverId;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final double rating;
  final double acceptanceRate;
  final String status;
  final DriverVehicle? vehicle;

  const DriverProfile({
    required this.id,
    required this.driverId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.avatarUrl,
    required this.rating,
    required this.acceptanceRate,
    required this.status,
    this.vehicle,
  });

  String get fullName => '$firstName $lastName';

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    final vehicleAssignment = json['vehicleAssignment'] as Map<String, dynamic>?;
    final vehicleJson = vehicleAssignment?['vehicle'] as Map<String, dynamic>? ??
        json['vehicle'] as Map<String, dynamic>?;

    return DriverProfile(
      id: json['id'] as String? ?? '',
      driverId: json['driverId'] as String? ?? json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      rating: toDouble(json['avgRating']) ?? toDouble(json['rating']) ?? 0.0,
      acceptanceRate: toDouble(json['acceptanceRate']) ?? 0.0,
      status: json['status'] as String? ?? 'active',
      vehicle: vehicleJson != null
          ? DriverVehicle.fromJson(vehicleJson)
          : null,
    );
  }
}
