import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/socket_service.dart';
import 'driver_provider.dart';
import 'driver_status_provider.dart';

// Location uses real GPS — set to true only if testing without a device/emulator GPS
const _devBypass = false;

// Dummy position: Valletta, Malta
Position _dummyPosition() => Position(
      latitude: AppConstants.defaultLat,
      longitude: AppConstants.defaultLng,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 45.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  if (_devBypass) return LocationPermission.whileInUse;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  return permission;
});

final currentPositionProvider = FutureProvider<Position>((ref) async {
  if (_devBypass) return _dummyPosition();

  final permission = await ref.watch(locationPermissionProvider.future);
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw Exception('Location permission denied');
  }
  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );
});

final locationStreamProvider = StreamProvider<Position>((ref) {
  if (_devBypass) {
    // Emit a dummy position every 5 seconds to simulate movement
    return Stream.periodic(const Duration(seconds: 5), (_) => _dummyPosition());
  }

  final permissionAsync = ref.watch(locationPermissionProvider);

  return permissionAsync.when(
    data: (permission) {
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          ),
        );
      }
      return Stream.error(Exception('Location permission not granted: $permission'));
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err),
  );
});

/// Sends location updates to backend every 3 seconds when driver is online.
final locationUpdateProvider = Provider<LocationUpdateService>((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  final socketService = ref.watch(socketServiceProvider);
  final driverStatus = ref.watch(driverStatusProvider);
  final service = LocationUpdateService(repository, socketService);

  if (driverStatus.isOnline || driverStatus.isOnRide) {
    service.startTracking();
  } else {
    service.stopTracking();
  }

  ref.onDispose(() => service.stopTracking());

  return service;
});

class LocationUpdateService {
  final dynamic _repository;
  final SocketService _socketService;
  Timer? _timer;
  bool _isTracking = false;

  LocationUpdateService(this._repository, this._socketService);

  void startTracking() {
    if (_isTracking) return;
    _isTracking = true;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _sendLocation());
  }

  void stopTracking() {
    _isTracking = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sendLocation() async {
    if (_devBypass) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _repository.updateLocation(
        lat: position.latitude,
        lng: position.longitude,
        heading: position.heading,
        speed: position.speed,
      );
      // Also emit via WebSocket for real-time updates
      _socketService.emitLocationUpdate(
        position.latitude,
        position.longitude,
        position.heading,
        position.speed,
      );
      if (kDebugMode) print('[Location] Sent: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      if (kDebugMode) print('[Location] Update failed: $e');
    }
  }
}
