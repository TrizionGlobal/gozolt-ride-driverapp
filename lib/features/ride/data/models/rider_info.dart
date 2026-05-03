import '../../../../core/utils/json_parse.dart';

class RiderInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String phone;
  final double rating;
  final String? city;

  const RiderInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.phone,
    required this.rating,
    this.city,
  });

  String get fullName => '$firstName $lastName';

  factory RiderInfo.fromJson(Map<String, dynamic> json) {
    return RiderInfo(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String? ?? '',
      rating: toDouble(json['avgRating']) ?? toDouble(json['rating']) ?? 0.0,
      city: json['city'] as String? ?? json['location'] as String?,
    );
  }
}
