enum DeliveryJobStage {
  accepted,
  navigatingToPickup,
  arrivedAtPickup,
  waitingForOrder,
  readyForPickup,
  pickupVerification,
  pickedUp,
  navigatingToCustomer,
  arrivedAtCustomer,
  handoverVerification,
  cashCollection,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case DeliveryJobStage.accepted:
        return 'Accepted';
      case DeliveryJobStage.navigatingToPickup:
        return 'Navigating to pickup';
      case DeliveryJobStage.arrivedAtPickup:
        return 'Arrived at pickup';
      case DeliveryJobStage.waitingForOrder:
        return 'Waiting for order';
      case DeliveryJobStage.readyForPickup:
        return 'Ready for pickup';
      case DeliveryJobStage.pickupVerification:
        return 'Pickup verification';
      case DeliveryJobStage.pickedUp:
        return 'Order picked up';
      case DeliveryJobStage.navigatingToCustomer:
        return 'On the way to customer';
      case DeliveryJobStage.arrivedAtCustomer:
        return 'Arrived at customer';
      case DeliveryJobStage.handoverVerification:
        return 'Delivery verification';
      case DeliveryJobStage.cashCollection:
        return 'Collecting cash';
      case DeliveryJobStage.completed:
        return 'Delivery completed';
      case DeliveryJobStage.cancelled:
        return 'Delivery cancelled';
    }
  }

  bool get isTerminal {
    return this == DeliveryJobStage.completed ||
        this == DeliveryJobStage.cancelled;
  }
}
