// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_payout_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DriverPayoutLogImpl _$$DriverPayoutLogImplFromJson(
        Map<String, dynamic> json) =>
    _$DriverPayoutLogImpl(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      supplierId: json['supplierId'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      deductions: (json['deductions'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DriverPayoutLogImplToJson(
        _$DriverPayoutLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'supplierId': instance.supplierId,
      'amount': instance.amount,
      'deductions': instance.deductions,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
