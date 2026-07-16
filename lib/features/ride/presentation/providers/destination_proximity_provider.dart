import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../driver/presentation/providers/location_provider.dart';
import '../../data/models/ride_status.dart';
import 'ride_session_provider.dart';

/// Distance in meters from the driver to the current destination.
final destinationDistanceProvider = Provider<double?>((ref) {
  final ride = ref.watch(rideSessionProvider);
  if (ride == null) return null;

  final positionAsync = ref.watch(locationStreamProvider);
  return positionAsync.when(
    data: (position) {
      double destLat;
      double destLng;
      
      if (ride.status.isPrePickup || ride.status == RideStatus.requested) {
        destLat = ride.pickupLat;
        destLng = ride.pickupLng;
      } else {
        destLat = ride.currentStop?.lat ?? ride.dropoffLat;
        destLng = ride.currentStop?.lng ?? ride.dropoffLng;
      }

      return Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        destLat,
        destLng,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Whether the driver is near the destination (within 50 meters).
final isNearDestinationProvider = Provider<bool>((ref) {
  final distance = ref.watch(destinationDistanceProvider);
  if (distance == null) return false;
  return distance <= 50.0;
});
