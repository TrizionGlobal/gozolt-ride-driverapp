enum PickupVerificationMethod {
  pickupPin,
}

extension PickupVerificationMethodX on PickupVerificationMethod {
  String get label {
    return 'Enter pickup PIN';
  }

  String get description {
    return 'Enter the pickup PIN provided by the restaurant or store.';
  }
}
