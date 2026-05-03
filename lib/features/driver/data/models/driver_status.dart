enum DriverStatus {
  online,
  offline,
  onRide;

  bool get isOnline => this == DriverStatus.online;
  bool get isOffline => this == DriverStatus.offline;
  bool get isOnRide => this == DriverStatus.onRide;
}
