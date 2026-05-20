class DriverEarningsBalance {
  final String id;
  final String driverId;
  final double totalEarnings;
  final double totalPaidOut;
  final double pendingPenalties;
  final double availableBalance;
  final DateTime updatedAt;
  final String? payoutDestination;

  const DriverEarningsBalance({
    required this.id,
    required this.driverId,
    required this.totalEarnings,
    required this.totalPaidOut,
    required this.pendingPenalties,
    required this.availableBalance,
    required this.updatedAt,
    this.payoutDestination,
  });

  factory DriverEarningsBalance.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return DriverEarningsBalance(
      id: json['id'] as String? ?? '',
      driverId: json['driverId'] as String? ?? '',
      totalEarnings: parseDouble(json['totalEarnings']),
      totalPaidOut: parseDouble(json['totalPaidOut']),
      pendingPenalties: parseDouble(json['pendingPenalties']),
      availableBalance: parseDouble(json['availableBalance']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : DateTime.now(),
      payoutDestination: json['payoutDestination'] as String?,
    );
  }
}
