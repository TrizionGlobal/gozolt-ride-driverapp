enum HandoverVerificationResult {
  idle,
  verifying,
  verified,
  failed,
  locked,
}

extension HandoverVerificationResultX on HandoverVerificationResult {
  bool get isVerifying {
    return this == HandoverVerificationResult.verifying;
  }

  bool get isVerified {
    return this == HandoverVerificationResult.verified;
  }

  bool get hasFailed {
    return this == HandoverVerificationResult.failed;
  }

  bool get isLocked {
    return this == HandoverVerificationResult.locked;
  }
}
