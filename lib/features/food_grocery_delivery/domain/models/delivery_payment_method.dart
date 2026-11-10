enum DeliveryPaymentMethod {
  card,
  cash;

  String get displayName {
    switch (this) {
      case DeliveryPaymentMethod.card:
        return 'Card';
      case DeliveryPaymentMethod.cash:
        return 'Cash';
    }
  }

  bool get requiresCashCollection {
    return this == DeliveryPaymentMethod.cash;
  }
}
