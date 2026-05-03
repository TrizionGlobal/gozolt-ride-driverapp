import '../../../../core/utils/json_parse.dart';

class DailyEarnings {
  final DateTime date;
  final double totalEarnings;
  final int tripCount;
  final double cashEarnings;
  final double cardEarnings;
  final double tipEarnings;

  const DailyEarnings({
    required this.date,
    required this.totalEarnings,
    required this.tripCount,
    required this.cashEarnings,
    required this.cardEarnings,
    this.tipEarnings = 0.0,
  });

  factory DailyEarnings.fromJson(Map<String, dynamic> json) {
    return DailyEarnings(
      date: DateTime.parse(json['date'] as String),
      totalEarnings: toDouble(json['totalEarnings']) ?? 0.0,
      tripCount: toInt(json['tripCount']),
      cashEarnings: toDouble(json['cashEarnings']) ?? 0.0,
      cardEarnings: toDouble(json['cardEarnings']) ?? 0.0,
      tipEarnings: toDouble(json['tipEarnings']) ?? 0.0,
    );
  }
}
