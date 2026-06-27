import '../../../../core/utils/json_parse.dart';

class DriverSupplier {
  final String id;
  final String companyName;
  final String? email;
  final String? contactPhone;
  final String? tradingName;
  final String? city;
  final String? country;

  const DriverSupplier({
    required this.id,
    required this.companyName,
    this.email,
    this.contactPhone,
    this.tradingName,
    this.city,
    this.country,
  });

  factory DriverSupplier.fromJson(Map<String, dynamic> json) {
    return DriverSupplier(
      id: json['id'] as String? ?? '',
      companyName: json['companyName'] as String? ?? 'Unknown',
      email: json['email'] as String?,
      contactPhone: json['contactPhone'] as String?,
      tradingName: json['tradingName'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
    );
  }
}

class DriverVehicle {
  final String id;
  final String make;
  final String model;
  final String plate;
  final String type;
  final String color;

  const DriverVehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.plate,
    required this.type,
    required this.color,
  });

  factory DriverVehicle.fromJson(Map<String, dynamic> json) {
    return DriverVehicle(
      id: json['id'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      plate: json['plateNumber'] as String? ?? json['plate'] as String? ?? '',
      type: json['vehicleType'] as String? ?? json['type'] as String? ?? 'standard',
      color: json['color'] as String? ?? '',
    );
  }
}

class DriverDocument {
  final String id;
  final String type;
  final String status;
  final String fileUrl;
  final String? uploadedName;

  const DriverDocument({
    required this.id,
    required this.type,
    required this.status,
    required this.fileUrl,
    this.uploadedName,
  });

  factory DriverDocument.fromJson(Map<String, dynamic> json) {
    return DriverDocument(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'UNKNOWN',
      status: json['status'] as String? ?? 'PENDING',
      fileUrl: json['fileUrl'] as String? ?? '',
      uploadedName: json['uploadedName'] as String?,
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
  final DriverSupplier? supplier;
  final List<DriverDocument> documents;
  final String? payoutBankName;
  final String? payoutAccountNumber;
  final String? payoutAccountHolder;
  final String? payoutSwiftCode;
  final bool editBankDetails;

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
    this.supplier,
    this.documents = const [],
    this.payoutBankName,
    this.payoutAccountNumber,
    this.payoutAccountHolder,
    this.payoutSwiftCode,
    this.editBankDetails = false,
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
      status: json['status'] as String? ?? 'ACTIVE',
      vehicle: vehicleJson != null ? DriverVehicle.fromJson(vehicleJson) : null,
      supplier: json['supplier'] != null ? DriverSupplier.fromJson(json['supplier'] as Map<String, dynamic>) : null,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => DriverDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      payoutBankName: json['payoutBankName'] as String?,
      payoutAccountNumber: json['payoutAccountNumber'] as String?,
      payoutAccountHolder: json['payoutAccountHolder'] as String?,
      payoutSwiftCode: json['payoutSwiftCode'] as String?,
      editBankDetails: json['editBankDetails'] as bool? ?? false,
    );
  }
}
