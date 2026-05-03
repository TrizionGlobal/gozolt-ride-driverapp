import '../../../../core/utils/json_parse.dart';

class EarningsSummary {
  final double totalEarnings;
  final double cashEarnings;
  final double cardEarnings;
  final int tripCount;
  final int cashTripCount;
  final int cardTripCount;
  final double tipEarnings;
  final int tipCount;

  const EarningsSummary({
    required this.totalEarnings,
    required this.cashEarnings,
    required this.cardEarnings,
    required this.tripCount,
    required this.cashTripCount,
    required this.cardTripCount,
    required this.tipEarnings,
    required this.tipCount,
  });

  const EarningsSummary.empty()
      : totalEarnings = 0.0,
        cashEarnings = 0.0,
        cardEarnings = 0.0,
        tripCount = 0,
        cashTripCount = 0,
        cardTripCount = 0,
        tipEarnings = 0.0,
        tipCount = 0;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      totalEarnings: toDouble(json['totalEarnings']) ?? 0.0,
      cashEarnings: toDouble(json['cashEarnings']) ?? 0.0,
      cardEarnings: toDouble(json['cardEarnings']) ?? 0.0,
      tripCount: toInt(json['completedRides']),
      cashTripCount: toInt(json['cashTripCount']),
      cardTripCount: toInt(json['cardTripCount']),
      tipEarnings: toDouble(json['tipEarnings']) ?? 0.0,
      tipCount: toInt(json['tipCount']),
    );
  }
}
