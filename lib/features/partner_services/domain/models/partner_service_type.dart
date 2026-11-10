enum PartnerServiceType {
  cabBooking,
  foodDelivery,
  groceryDelivery;

  String get apiValue {
    switch (this) {
      case PartnerServiceType.cabBooking:
        return 'CAB_BOOKING';
      case PartnerServiceType.foodDelivery:
        return 'FOOD_DELIVERY';
      case PartnerServiceType.groceryDelivery:
        return 'GROCERY_DELIVERY';
    }
  }

  String get displayName {
    switch (this) {
      case PartnerServiceType.cabBooking:
        return 'Cab Booking';
      case PartnerServiceType.foodDelivery:
        return 'Food Delivery';
      case PartnerServiceType.groceryDelivery:
        return 'Grocery Delivery';
    }
  }

  String get description {
    switch (this) {
      case PartnerServiceType.cabBooking:
        return 'Accept and complete passenger trips';
      case PartnerServiceType.foodDelivery:
        return 'Deliver orders from restaurants';
      case PartnerServiceType.groceryDelivery:
        return 'Deliver orders from grocery stores';
    }
  }

  bool get isDelivery {
    return this == PartnerServiceType.foodDelivery ||
        this == PartnerServiceType.groceryDelivery;
  }

  static PartnerServiceType? fromApiValue(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'CAB_BOOKING':
      case 'CAB':
      case 'RIDE':
        return PartnerServiceType.cabBooking;

      case 'FOOD_DELIVERY':
      case 'FOOD':
        return PartnerServiceType.foodDelivery;

      case 'GROCERY_DELIVERY':
      case 'GROCERY':
        return PartnerServiceType.groceryDelivery;

      default:
        return null;
    }
  }
}
