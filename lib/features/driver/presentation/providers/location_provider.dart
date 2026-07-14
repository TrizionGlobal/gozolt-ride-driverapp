import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/socket_service.dart';
import 'driver_provider.dart';
import 'driver_status_provider.dart';

// Location uses real GPS

final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  return await Geolocator.checkPermission();
});

final currentPositionProvider = FutureProvider<Position>((ref) async {
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

final driverPositionProvider = StateProvider<Position?>((ref) => null);

/// Sends location updates to backend every 3 seconds when driver is online.
final locationUpdateProvider = Provider<LocationUpdateService>((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  final socketService = ref.watch(socketServiceProvider);
  final driverStatus = ref.watch(driverStatusProvider);
  
  final service = LocationUpdateService(repository, socketService, (pos) {
    ref.read(driverPositionProvider.notifier).state = pos;
  });

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
  final void Function(Position) _onPositionUpdate;
  Timer? _timer;
  bool _isTracking = false;
  Position? _lastPosition;
  double _lastHeading = 0.0;

  LocationUpdateService(this._repository, this._socketService, this._onPositionUpdate);

  void startTracking() {
    if (_isTracking) return;
    _isTracking = true;
    _sendLocation(); // Send immediately
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _sendLocation());
  }

  void stopTracking() {
    _isTracking = false;
    _timer?.cancel();
    _timer = null;
    _lastPosition = null;
  }

  Future<void> _sendLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (position.isMocked) {
        debugPrint('Fake location detected during tracking. Skipping backend update.');
        return;
      }

      double currentHeading = position.heading;

      // If heading is invalid (often 0.0 on emulators) or we have moved, calculate bearing manually
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude, _lastPosition!.longitude,
          position.latitude, position.longitude,
        );

        if (distance > 1.0) {
          // Calculate heading from last position to new position
          currentHeading = Geolocator.bearingBetween(
            _lastPosition!.latitude, _lastPosition!.longitude,
            position.latitude, position.longitude,
          );
          if (currentHeading < 0) currentHeading += 360.0;
          _lastHeading = currentHeading;
        } else {
          currentHeading = _lastHeading;
        }
      } else {
        _lastHeading = currentHeading;
      }

      final updatedPosition = Position(
        longitude: position.longitude,
        latitude: position.latitude,
        timestamp: position.timestamp,
        accuracy: position.accuracy,
        altitude: position.altitude,
        altitudeAccuracy: position.altitudeAccuracy,
        heading: currentHeading,
        headingAccuracy: position.headingAccuracy,
        speed: position.speed,
        speedAccuracy: position.speedAccuracy,
        floor: position.floor,
        isMocked: position.isMocked,
      );

      _lastPosition = updatedPosition;
      
      _onPositionUpdate(updatedPosition);
      
      await _repository.updateLocation(
        lat: updatedPosition.latitude,
        lng: updatedPosition.longitude,
        heading: updatedPosition.heading,
        speed: updatedPosition.speed,
      );
      // Also emit via WebSocket for real-time updates
      _socketService.emitLocationUpdate(
        updatedPosition.latitude,
        updatedPosition.longitude,
        updatedPosition.heading,
        updatedPosition.speed,
      );
      if (kDebugMode) print('[Location] Sent: ${updatedPosition.latitude}, ${updatedPosition.longitude} Heading: ${updatedPosition.heading}');
    } catch (e) {
      if (kDebugMode) print('[Location] Update failed: $e');
    }
  }
}
