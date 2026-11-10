enum PickupVerificationResult {
  idle,
  verifying,
  verified,
  failed,
  locked,
}

extension PickupVerificationResultX on PickupVerificationResult {
  bool get isVerifying {
    return this == PickupVerificationResult.verifying;
  }

  bool get isVerified {
    return this == PickupVerificationResult.verified;
  }

  bool get hasFailed {
    return this == PickupVerificationResult.failed;
  }

  bool get isLocked {
    return this == PickupVerificationResult.locked;
  }
}
