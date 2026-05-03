enum RideStatus {
  requested,
  accepted,
  driverEnRoute,
  driverArrived,
  inProgress,
  completed,
  cancelled,
  noShowUser,
  noShowDriver,
  scheduled,
  noDrivers;

  bool get isPrePickup =>
      this == accepted ||
      this == driverEnRoute ||
      this == driverArrived;

  bool get isActive => this == inProgress;
  bool get isTerminal =>
      this == completed ||
      this == cancelled ||
      this == noShowUser ||
      this == noShowDriver;

  String toBackendString() {
    return switch (this) {
      RideStatus.requested => 'REQUESTED',
      RideStatus.accepted => 'ACCEPTED',
      RideStatus.driverEnRoute => 'DRIVER_EN_ROUTE',
      RideStatus.driverArrived => 'DRIVER_ARRIVED',
      RideStatus.inProgress => 'IN_PROGRESS',
      RideStatus.completed => 'COMPLETED',
      RideStatus.cancelled => 'CANCELLED',
      RideStatus.noShowUser => 'NO_SHOW_USER',
      RideStatus.noShowDriver => 'NO_SHOW_DRIVER',
      RideStatus.scheduled => 'SCHEDULED',
      RideStatus.noDrivers => 'NO_DRIVERS',
    };
  }

  factory RideStatus.fromString(String value) {
    return switch (value) {
      'REQUESTED' => RideStatus.requested,
      'OFFERED' => RideStatus.requested,
      'ACCEPTED' => RideStatus.accepted,
      'DRIVER_EN_ROUTE' => RideStatus.driverEnRoute,
      'DRIVER_ARRIVED' => RideStatus.driverArrived,
      'IN_PROGRESS' => RideStatus.inProgress,
      'COMPLETED' => RideStatus.completed,
      'CANCELLED' => RideStatus.cancelled,
      'NO_SHOW_USER' => RideStatus.noShowUser,
      'NO_SHOW_DRIVER' => RideStatus.noShowDriver,
      'SCHEDULED' => RideStatus.scheduled,
      'NO_DRIVERS' => RideStatus.noDrivers,
      _ => RideStatus.requested,
    };
  }
}
