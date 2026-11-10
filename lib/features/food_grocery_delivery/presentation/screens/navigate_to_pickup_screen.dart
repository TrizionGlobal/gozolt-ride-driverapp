import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../driver/presentation/providers/location_provider.dart';
import '../../../partner_services/domain/models/partner_service_type.dart';
import '../providers/food_grocery_delivery_session_provider.dart';

class NavigateToPickupScreen extends ConsumerStatefulWidget {
  const NavigateToPickupScreen({
    super.key,
    required this.serviceType,
    required this.onBack,
    required this.onArrivedAtPickup,
  });

  final PartnerServiceType serviceType;
  final VoidCallback onBack;
  final VoidCallback onArrivedAtPickup;

  @override
  ConsumerState<NavigateToPickupScreen> createState() =>
      _NavigateToPickupScreenState();
}

class _NavigateToPickupScreenState
    extends ConsumerState<NavigateToPickupScreen> {
  GoogleMapController? _mapController;

  static const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#2C2C2C"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  }
]
''';

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _openExternalNavigation(
    double latitude,
    double longitude,
  ) async {
    final googleNavigation = Uri.parse(
      'google.navigation:q=$latitude,$longitude&mode=d',
    );

    final googleMapsWeb = Uri.parse(
      'https://www.google.com/maps/dir/'
      '?api=1&destination=$latitude,$longitude'
      '&travelmode=driving',
    );

    final appleMaps = Uri.parse(
      'https://maps.apple.com/'
      '?daddr=$latitude,$longitude&dirflg=d',
    );

    try {
      if (await canLaunchUrl(googleNavigation)) {
        await launchUrl(googleNavigation);
        return;
      }

      if (Platform.isIOS && await canLaunchUrl(appleMaps)) {
        await launchUrl(
          appleMaps,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      await launchUrl(
        googleMapsWeb,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open navigation.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  Future<void> _callBusiness(String phone) async {
    final uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    try {
      final launched = await launchUrl(uri);

      if (!launched && mounted) {
        _showCallError();
      }
    } catch (_) {
      if (mounted) {
        _showCallError();
      }
    }
  }

  void _showCallError() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open the phone application.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final session = ref.watch(
      foodGroceryDeliverySessionProvider(
        widget.serviceType,
      ),
    );

    final job = session.activeJob;

    if (job == null) {
      return _MissingPickupView(
        isDark: isDark,
        onReturn: widget.onBack,
      );
    }

    final position = ref
        .watch(
          currentPositionProvider,
        )
        .valueOrNull;

    final pickupLocation = LatLng(
      job.pickupLatitude,
      job.pickupLongitude,
    );

    final driverLocation = position == null
        ? null
        : LatLng(
            position.latitude,
            position.longitude,
          );

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickupLocation,
        infoWindow: InfoWindow(
          title: job.businessName,
          snippet: job.pickupAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        ),
      ),
      if (driverLocation != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: driverLocation,
          infoWindow: const InfoWindow(
            title: 'Your location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
    };

    final polylines = <Polyline>{
      if (driverLocation != null)
        Polyline(
          polylineId: const PolylineId(
            'temporary-pickup-route',
          ),
          points: [
            driverLocation,
            pickupLocation,
          ],
          color: AppColors.primaryGold,
          width: 5,
        ),
    };

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarker : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDarker : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onBack,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        title: Text(
          job.isFoodDelivery ? 'Navigate to restaurant' : 'Navigate to store',
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              style: isDark ? _darkMapStyle : null,
              initialCameraPosition: CameraPosition(
                target: pickupLocation,
                zoom: 14.5,
              ),
              markers: markers,
              polylines: polylines,
              compassEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) async {
                _mapController = controller;

                if (driverLocation != null) {
                  await Future<void>.delayed(
                    const Duration(milliseconds: 300),
                  );

                  if (!mounted) {
                    return;
                  }

                  final southwest = LatLng(
                    driverLocation.latitude < pickupLocation.latitude
                        ? driverLocation.latitude
                        : pickupLocation.latitude,
                    driverLocation.longitude < pickupLocation.longitude
                        ? driverLocation.longitude
                        : pickupLocation.longitude,
                  );

                  final northeast = LatLng(
                    driverLocation.latitude > pickupLocation.latitude
                        ? driverLocation.latitude
                        : pickupLocation.latitude,
                    driverLocation.longitude > pickupLocation.longitude
                        ? driverLocation.longitude
                        : pickupLocation.longitude,
                  );

                  await controller.animateCamera(
                    CameraUpdate.newLatLngBounds(
                      LatLngBounds(
                        southwest: southwest,
                        northeast: northeast,
                      ),
                      64,
                    ),
                  );
                }
              },
            ),
          ),
          _PickupInformationPanel(
            isDark: isDark,
            businessTypeLabel: job.businessTypeLabel,
            businessName: job.businessName,
            pickupAddress: job.pickupAddress,
            onCall: job.businessPhone == null
                ? null
                : () => _callBusiness(
                      job.businessPhone!,
                    ),
            onOpenNavigation: () {
              _openExternalNavigation(
                job.pickupLatitude,
                job.pickupLongitude,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            12,
          ),
          color:
              isDark ? AppColors.backgroundSecondary : AppColors.surfaceLight,
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: widget.onArrivedAtPickup,
              icon: const Icon(
                Icons.store_mall_directory_outlined,
                size: 20,
              ),
              label: const Text('Arrived at pickup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: const Color(0xFF04213C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickupInformationPanel extends StatelessWidget {
  const _PickupInformationPanel({
    required this.isDark,
    required this.businessTypeLabel,
    required this.businessName,
    required this.pickupAddress,
    required this.onCall,
    required this.onOpenNavigation,
  });

  final bool isDark;
  final String businessTypeLabel;
  final String businessName;
  final String pickupAddress;
  final VoidCallback? onCall;
  final VoidCallback onOpenNavigation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        15,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            businessTypeLabel,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            businessName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleMedium.copyWith(
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            pickupAddress,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              if (onCall != null) ...[
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: onCall,
                      icon: const Icon(
                        Icons.call_outlined,
                        size: 19,
                      ),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGold,
                        side: const BorderSide(
                          color: AppColors.primaryGold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onOpenNavigation,
                    icon: const Icon(
                      Icons.navigation_rounded,
                      size: 19,
                    ),
                    label: const Text('Open navigation'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGold,
                      side: const BorderSide(
                        color: AppColors.primaryGold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissingPickupView extends StatelessWidget {
  const _MissingPickupView({
    required this.isDark,
    required this.onReturn,
  });

  final bool isDark;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDarker : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_off_outlined,
                  size: 58,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 18),
                Text(
                  'Pickup details unavailable',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onReturn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: const Color(0xFF04213C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Return to details'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
