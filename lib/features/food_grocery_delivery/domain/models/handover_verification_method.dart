enum HandoverVerificationMethod {
  deliveryPin,
}

extension HandoverVerificationMethodX on HandoverVerificationMethod {
  String get label {
    return 'Enter delivery PIN';
  }

  String get description {
    return 'Enter the delivery PIN provided by the customer.';
  }
}
