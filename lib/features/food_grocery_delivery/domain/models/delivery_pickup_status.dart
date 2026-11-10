/// Preparation status reported by the restaurant or grocery store.
///
/// TODO(FOOD_GROCERY_API):
/// Map backend preparation-status values to this enum.
enum DeliveryPickupStatus {
  preparing,
  pickingItems,
  packing,
  readyForPickup,
}

extension DeliveryPickupStatusX on DeliveryPickupStatus {
  bool get isReadyForPickup {
    return this == DeliveryPickupStatus.readyForPickup;
  }

  String label({required bool isFoodDelivery}) {
    switch (this) {
      case DeliveryPickupStatus.preparing:
        return isFoodDelivery ? 'Preparing your order' : 'Preparing your items';

      case DeliveryPickupStatus.pickingItems:
        return isFoodDelivery
            ? 'Preparing your order'
            : 'Picking grocery items';

      case DeliveryPickupStatus.packing:
        return isFoodDelivery ? 'Packing your order' : 'Packing grocery items';

      case DeliveryPickupStatus.readyForPickup:
        return 'Ready for pickup';
    }
  }

  String description({required bool isFoodDelivery}) {
    switch (this) {
      case DeliveryPickupStatus.preparing:
        return isFoodDelivery
            ? 'The restaurant is preparing the customer’s order.'
            : 'The store is preparing the customer’s items.';

      case DeliveryPickupStatus.pickingItems:
        return 'The store is currently picking the customer’s grocery items.';

      case DeliveryPickupStatus.packing:
        return isFoodDelivery
            ? 'The restaurant is packing the order for collection.'
            : 'The store is packing the grocery order for collection.';

      case DeliveryPickupStatus.readyForPickup:
        return isFoodDelivery
            ? 'The restaurant has confirmed that the order is ready.'
            : 'The store has confirmed that the order is ready.';
    }
  }
}
