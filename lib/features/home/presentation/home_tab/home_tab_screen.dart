import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/custom_marker_painter.dart';
import '../../../driver/presentation/providers/location_provider.dart';
import '../../../driver/presentation/providers/driver_status_provider.dart';
import '../../../ride/data/models/ride_status.dart';
import '../../../ride/presentation/providers/ride_session_provider.dart';
import '../../../ride/presentation/screens/active_ride_card.dart';
import '../../../ride/presentation/screens/navigate_to_pickup_card.dart';
import '../../../ride/presentation/screens/ride_request_sheet.dart';
import '../../../ride/presentation/screens/collect_amount_screen.dart';
import '../../../ride/presentation/screens/ride_summary_sheet.dart';
import 'widgets/go_online_button.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/map_overlay_buttons.dart';
import '../../../ride/presentation/widgets/ride_metrics_bubbles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';

class HomeTabScreen extends ConsumerStatefulWidget {
  const HomeTabScreen({super.key});

  @override
  ConsumerState<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends ConsumerState<HomeTabScreen>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;

  static const _darkMapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#212121"}]},
    {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
    {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},
    {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#181818"}]},
    {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
    {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},
    {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}
  ]''';

  // Custom marker icons
  BitmapDescriptor? _driverIcon;
  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _dropoffIcon;
  BitmapDescriptor? _stopIcon;

  // Route polyline points (fetched from Directions API)
  List<LatLng>? _toPickupRoute;
  List<LatLng>? _toDropoffRoute;
  String? _lastRouteKey;

  // Default location from config
  static final _defaultLocation = LatLng(AppConstants.defaultLat, AppConstants.defaultLng);
  static const _defaultZoom = 15.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCustomMarkers();
  }

  Future<void> _loadCustomMarkers() async {
    final results = await Future.wait([
      CustomMarkerPainter.carAssetMarker(),
      CustomMarkerPainter.pickupMarker(),
      CustomMarkerPainter.dropoffMarker(),
      CustomMarkerPainter.stopMarker(),
    ]);
    if (mounted) {
      setState(() {
        _driverIcon = results[0];
        _pickupIcon = results[1];
        _dropoffIcon = results[2];
        _stopIcon = results[3];
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-apply map style after returning from external app (e.g. Google Maps navigation)
      final isDark = Theme.of(context).brightness == Brightness.dark;
      _mapController?.setMapStyle(isDark ? _darkMapStyle : null);
      // Force re-fetch of route polylines
      _lastRouteKey = null;
      _toPickupRoute = null;
      _toDropoffRoute = null;
      // Trigger rebuild to refresh markers and polylines
      setState(() {});
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _goToCurrentLocation();
  }

  Future<void> _goToCurrentLocation() async {
    try {
      // 1. Try to use the stream provider's latest value
      final streamPos = ref.read(locationStreamProvider).valueOrNull;
      if (streamPos != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(streamPos.latitude, streamPos.longitude),
            _defaultZoom,
          ),
        );
        return;
      }

      // 2. Try to use the current position provider's cached value
      final cachedPos = ref.read(currentPositionProvider).valueOrNull;
      if (cachedPos != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(cachedPos.latitude, cachedPos.longitude),
            _defaultZoom,
          ),
        );
        return;
      }

      // 3. Fallback: Request fresh position directly from Geolocator after checks
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          SnackbarUtils.showError(context, 'Location services are disabled. Please enable them in your device settings.');
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            SnackbarUtils.showError(context, 'Location permission denied.');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          SnackbarUtils.showError(context, 'Location permissions are permanently denied. Please enable them in app settings.');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          _defaultZoom,
        ),
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        SnackbarUtils.showError(context, 'Error getting location: $e');
      }
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Driver marker — use stream position, fallback to current position provider
    final streamPosition = ref.watch(locationStreamProvider).valueOrNull;
    final fallbackPosition = ref.watch(currentPositionProvider).valueOrNull;
    final position = streamPosition ?? fallbackPosition;
    if (position != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(position.latitude, position.longitude),
          icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow),
          anchor: const Offset(0.5, 0.5),
          rotation: position.heading,
        ),
      );
    }



    // Ride markers
    final ride = ref.watch(rideSessionProvider);
    if (ride != null && !ride.status.isTerminal) {
      // Pickup marker
      if (ride.status.isPrePickup || ride.status == RideStatus.requested) {
        markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(ride.pickupLat, ride.pickupLng),
            icon: _pickupIcon ?? BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed),
          ),
        );
      }

      // Intermediate stop markers
      if (ride.hasStops) {
        for (int i = 0; i < ride.stops.length; i++) {
          final stop = ride.stops[i];
          if (!stop.completed) {
            markers.add(
              Marker(
                markerId: MarkerId('stop_$i'),
                position: LatLng(stop.lat, stop.lng),
                icon: _stopIcon ?? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange),
              ),
            );
          }
        }
      }

      // Dropoff marker
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(ride.dropoffLat, ride.dropoffLng),
          icon: _dropoffIcon ?? BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen),
        ),
      );
    }

    return markers;
  }

  LatLng _getInitialTarget() {
    final positionAsync = ref.read(currentPositionProvider);
    return positionAsync.when(
      data: (p) => LatLng(p.latitude, p.longitude),
      loading: () => _defaultLocation,
      error: (err, stack) => _defaultLocation,
    );
  }

  /// Build a LatLngBounds that contains all given points, with padding.
  LatLngBounds _boundsFromLocations(List<LatLng> points) {
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final p in points) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Get the driver's current LatLng or null (one-shot read for callbacks).
  LatLng? _driverLatLng() {
    final p = ref.read(locationStreamProvider).valueOrNull;
    return p != null ? LatLng(p.latitude, p.longitude) : null;
  }

  Future<void> _fetchDirectionsRoute(LatLng origin, LatLng destination, {required bool isPickupRoute}) async {
    final routeKey = '${isPickupRoute ? 'pickup' : 'dropoff'}_${origin.latitude.toStringAsFixed(2)},${origin.longitude.toStringAsFixed(2)}_${destination.latitude.toStringAsFixed(2)},${destination.longitude.toStringAsFixed(2)}';
    if (_lastRouteKey == routeKey) return;
    _lastRouteKey = routeKey;

    try {
      final dio = Dio();
      // Use OSRM (free, no API key needed) for road-following routes
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}'
          '?overview=full&geometries=polyline';

      final response = await dio.get(url);
      final data = response.data;

      if (data is Map<String, dynamic> &&
          data['code'] == 'Ok' &&
          (data['routes'] as List).isNotEmpty) {
        final encodedPolyline = data['routes'][0]['geometry'] as String;
        final points = _decodePolyline(encodedPolyline);
        if (mounted) {
          setState(() {
            if (isPickupRoute) {
              _toPickupRoute = points;
            } else {
              _toDropoffRoute = points;
            }
          });
        }
      } else {
        debugPrint('OSRM route error: ${data is Map ? data['code'] : 'unknown'}');
      }
    } catch (e) {
      debugPrint('Route fetch failed: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  Set<Polyline> _buildPolylines() {
    final polylines = <Polyline>{};
    final ride = ref.watch(rideSessionProvider);
    final driverPos = _driverLatLng();

    if (ride == null || driverPos == null || ride.status.isTerminal) {
      return polylines;
    }

    if (ride.status == RideStatus.driverEnRoute ||
        ride.status == RideStatus.accepted ||
        ride.status == RideStatus.driverArrived) {
      final pickupPos = LatLng(ride.pickupLat, ride.pickupLng);
      // Fetch route if not cached
      _fetchDirectionsRoute(driverPos, pickupPos, isPickupRoute: true);
      final routePoints = _toPickupRoute ?? [driverPos, pickupPos];
      polylines.add(Polyline(
        polylineId: const PolylineId('to_pickup'),
        points: routePoints,
        color: const Color(0xFFD4A843),
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ));
    } else if (ride.status == RideStatus.inProgress) {
      final destination = ride.currentStop != null
          ? LatLng(ride.currentStop!.lat, ride.currentStop!.lng)
          : LatLng(ride.dropoffLat, ride.dropoffLng);
      // Fetch route if not cached
      _fetchDirectionsRoute(driverPos, destination, isPickupRoute: false);
      final routePoints = _toDropoffRoute ?? [driverPos, destination];
      polylines.add(Polyline(
        polylineId: const PolylineId('to_dropoff'),
        points: routePoints,
        color: const Color(0xFF4CAF50),
        width: 4,
      ));
    }

    return polylines;
  }

  @override
  Widget build(BuildContext context) {
    // Keep location stream alive
    ref.watch(locationStreamProvider);

    // When GPS resolves, animate map to current location
    ref.listen(currentPositionProvider, (prev, next) {
      next.whenOrNull(
        data: (pos) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(pos.latitude, pos.longitude),
              _defaultZoom,
            ),
          );
        },
      );
    });

    // Zoom map to show driver + pickup/dropoff when ride status or destination changes
    ref.listen(rideSessionProvider, (prev, next) {
      // Ride was cancelled by user (prev had a ride, now null)
      if (prev != null && next == null) {
        // Clear cached routes
        setState(() {
          _toPickupRoute = null;
          _toDropoffRoute = null;
          _lastRouteKey = null;
        });
        // Show cancellation dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Ride Cancelled',
              style: AppTextStyles.titleMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.textPrimary 
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'The rider has cancelled this ride. You are now back online.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.textSecondary 
                    : AppColors.textSecondaryLight,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('OK', style: TextStyle(color: AppColors.primaryGold)),
              ),
            ],
          ),
        );
        return;
      }
      if (next == null) return;

      // Detect destination change (dropoff coordinates changed while in progress)
      final destinationChanged = prev != null &&
          next.status == RideStatus.inProgress &&
          (prev.dropoffLat != next.dropoffLat || prev.dropoffLng != next.dropoffLng);

      if (destinationChanged) {
        // Clear cached dropoff route so polyline is re-fetched to new destination
        setState(() {
          _toDropoffRoute = null;
          _lastRouteKey = null;
        });
        // Re-zoom map to show driver + new destination
        final driverPos = _driverLatLng();
        final dropoff = LatLng(next.dropoffLat, next.dropoffLng);
        if (driverPos != null) {
          final bounds = _boundsFromLocations([driverPos, dropoff]);
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 80),
          );
        } else {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(dropoff, 14),
          );
        }
      }

      if (prev?.status != next.status) {
        final driverPos = _driverLatLng();
        if (next.status == RideStatus.driverEnRoute ||
            next.status == RideStatus.accepted) {
          final pickup = LatLng(next.pickupLat, next.pickupLng);
          if (driverPos != null) {
            final bounds = _boundsFromLocations([driverPos, pickup]);
            _mapController?.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 80),
            );
          } else {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(pickup, 14),
            );
          }
        } else if (next.status == RideStatus.inProgress) {
          final dropoff = LatLng(next.dropoffLat, next.dropoffLng);
          if (driverPos != null) {
            final bounds = _boundsFromLocations([driverPos, dropoff]);
            _mapController?.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 80),
            );
          } else {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(dropoff, 14),
            );
          }
        }
      }
    });

    final ride = ref.watch(rideSessionProvider);
    final isOnRide = ride != null;
    final driverStatus = ref.watch(driverStatusProvider);
    final isBottomNavBarVisible = !driverStatus.isOnline && !isOnRide;
    final bottomOffset = isBottomNavBarVisible ? 104.0 : 16.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Full-screen Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _getInitialTarget(),
              zoom: _defaultZoom,
            ),
            style: Theme.of(context).brightness == Brightness.dark ? _darkMapStyle : null,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            markers: _buildMarkers(),
            polylines: _buildPolylines(),
          ),

          // Top bar overlay (hidden during ride)
          if (!isOnRide)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HomeTopBar(),
            ),

          // Bottom overlay: SOS/Location + Go Online (hidden during ride)
          if (!isOnRide)
            Positioned(
              bottom: bottomOffset,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MapOverlayButtons(
                    onMyLocationTap: _goToCurrentLocation,
                  ),
                  const SizedBox(height: 16),
                  const GoOnlineButton(),
                ],
              ),
            ),

          // Ride overlays
          if (ride != null) ..._buildRideOverlays(ride.status),
        ],
      ),
    );
  }

  List<Widget> _buildRideOverlays(RideStatus status) {
    return switch (status) {
      RideStatus.requested => [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _AnimatedRideRequest(
              child: const RideRequestSheet(),
            ),
          ),
        ],
      RideStatus.driverEnRoute ||
      RideStatus.accepted ||
      RideStatus.driverArrived =>
        [
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavigateToPickupCard(),
          ),
        ],
      RideStatus.inProgress => [
          Positioned.fill(
            child: Consumer(
              builder: (context, ref, _) {
                final showCollect = ref.watch(showCollectAmountProvider);
                if (showCollect) {
                  return const CollectAmountScreen();
                }
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const RideMetricsBubbles(),
                      const SizedBox(height: 12),
                      const ActiveRideCard(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      RideStatus.completed => [
          Positioned.fill(
            child: Consumer(
              builder: (context, ref, _) {
                final showCollect = ref.watch(showCollectAmountProvider);
                if (showCollect) {
                  return const CollectAmountScreen();
                }
                return const Align(
                  alignment: Alignment.bottomCenter,
                  child: RideSummarySheet(),
                );
              },
            ),
          ),
        ],
      RideStatus.cancelled ||
      RideStatus.noShowUser ||
      RideStatus.noShowDriver ||
      RideStatus.scheduled ||
      RideStatus.noDrivers =>
        [],
    };
  }
}

/// Slide-in animation for ride request coming from the top.
class _AnimatedRideRequest extends StatefulWidget {
  final Widget child;

  const _AnimatedRideRequest({required this.child});

  @override
  State<_AnimatedRideRequest> createState() => _AnimatedRideRequestState();
}

class _AnimatedRideRequestState extends State<_AnimatedRideRequest>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}

