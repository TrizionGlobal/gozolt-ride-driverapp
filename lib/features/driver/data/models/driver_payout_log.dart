import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_payout_log.freezed.dart';
part 'driver_payout_log.g.dart';

@freezed
class DriverPayoutLog with _$DriverPayoutLog {
  const factory DriverPayoutLog({
    required String id,
    required String driverId,
    required String supplierId,
    @Default(0) double amount,
    @Default(0) double deductions,
    int? totalRides,
    double? totalFare,
    String? notes,
    required DateTime createdAt,
  }) = _DriverPayoutLog;

  factory DriverPayoutLog.fromJson(Map<String, dynamic> json) => _$DriverPayoutLogFromJson(json);
}
