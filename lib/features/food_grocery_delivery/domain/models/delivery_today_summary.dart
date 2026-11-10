class DeliveryTodaySummary {
  const DeliveryTodaySummary({
    this.completedDeliveries = 0,
    this.deliveryEarnings = 0,
    this.pendingEarnings = 0,
    this.cashCollected = 0,
  });

  final int completedDeliveries;
  final double deliveryEarnings;
  final double pendingEarnings;
  final double cashCollected;

  static const empty = DeliveryTodaySummary();
}
