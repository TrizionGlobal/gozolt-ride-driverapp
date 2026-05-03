import '../../../../core/utils/json_parse.dart';

class RideStop {
  final String id;
  final String address;
  final double lat;
  final double lng;
  final bool completed;

  const RideStop({
    required this.id,
    required this.address,
    required this.lat,
    required this.lng,
    this.completed = false,
  });

  RideStop copyWith({bool? completed}) {
    return RideStop(
      id: id,
      address: address,
      lat: lat,
      lng: lng,
      completed: completed ?? this.completed,
    );
  }

  factory RideStop.fromJson(Map<String, dynamic> json) {
    return RideStop(
      id: json['id'] as String? ?? '',
      address: json['address'] as String? ?? '',
      lat: toDouble(json['latitude']) ?? toDouble(json['lat']) ?? 0.0,
      lng: toDouble(json['longitude']) ?? toDouble(json['lng']) ?? 0.0,
      completed: json['arrivedAt'] != null || (json['completed'] as bool? ?? false),
    );
  }
}
