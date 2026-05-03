import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/socket_service.dart';
import '../../data/models/ride.dart';
import '../../data/models/ride_status.dart';
import '../../data/models/ride_stop.dart';
import '../../data/models/ride_summary.dart';
import '../../data/models/rider_info.dart';
import '../../domain/repositories/ride_repository.dart';
import '../../../driver/data/models/driver_status.dart';
import '../../../driver/presentation/providers/driver_status_provider.dart';
import '../../../driver/presentation/providers/earnings_provider.dart';
import '../../data/models/chat_message.dart';
import 'chat_provider.dart';
import 'ride_provider.dart';

/// Holds the ride summary after completion so the summary sheet can read it.
final rideSummaryProvider = StateProvider<RideSummary?>((ref) => null);

/// Countdown seconds remaining for ride request.
final rideRequestCountdownProvider = StateProvider<int>((ref) => 0);

/// Max countdown seconds (from socket event's timeoutSeconds).
final rideRequestMaxCountdownProvider = StateProvider<int>((ref) => 15);

/// Whether to show the collect amount screen after ride completion.
final showCollectAmountProvider = StateProvider<bool>((ref) => false);

/// Incoming destination change request data for the active ride.
final destinationChangeRequestProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

final rideSessionProvider =
    StateNotifierProvider<RideSessionNotifier, Ride?>((ref) {
  final repository = ref.watch(rideRepositoryProvider);
  final driverStatusNotifier = ref.read(driverStatusProvider.notifier);
  final socketService = ref.watch(socketServiceProvider);
  return RideSessionNotifier(
    repository: repository,
    driverStatusNotifier: driverStatusNotifier,
    socketService: socketService,
    ref: ref,
  );
});

class RideSessionNotifier extends StateNotifier<Ride?> {
  final RideRepository _repository;
  final DriverStatusNotifier _driverStatusNotifier;
  final SocketService _socketService;
  final Ref _ref;
  Timer? _countdownTimer;
  StreamSubscription<Map<String, dynamic>>? _rideRequestSub;
  StreamSubscription<Map<String, dynamic>>? _destinationChangeSub;
  StreamSubscription<Map<String, dynamic>>? _chatSub;
  StreamSubscription<Map<String, dynamic>>? _statusChangeSub;

  RideSessionNotifier({
    required RideRepository repository,
    required DriverStatusNotifier driverStatusNotifier,
    required SocketService socketService,
    required Ref ref,
  })  : _repository = repository,
        _driverStatusNotifier = driverStatusNotifier,
        _socketService = socketService,
        _ref = ref,
        super(null) {
    _rideRequestSub = _socketService.onRideRequest.listen((socketData) async {
      if (kDebugMode) print('[RideSession] Socket ride:request:new received: $socketData');

      // Ignore ride requests if driver is not online
      final driverStatus = _ref.read(driverStatusProvider);
      if (driverStatus != DriverStatus.online) {
        if (kDebugMode) print('[RideSession] Ignoring ride request — driver status is $driverStatus');
        return;
      }

      // Support both camelCase and snake_case field names
      final rideId = socketData['rideId'] as String? ?? socketData['ride_id'] as String? ?? socketData['id'] as String?;
      if (rideId == null) {
        if (kDebugMode) print('[RideSession] ERROR: No rideId in socket data');
        return;
      }

      final timeoutSeconds = (socketData['timeoutSeconds'] as num?)?.toInt() ??
          (socketData['timeout_seconds'] as num?)?.toInt() ?? 15;
      final etaMinutes = (socketData['etaMinutes'] as num?)?.toInt() ??
          (socketData['eta_minutes'] as num?)?.toInt() ?? 0;
      final distanceKm = (socketData['distanceKm'] as num?)?.toDouble() ??
          (socketData['distance_km'] as num?)?.toDouble() ?? 0.0;

      try {
        if (kDebugMode) print('[RideSession] Fetching ride details for $rideId...');
        final result = await _repository.getRideDetails(rideId);
        switch (result) {
          case ApiSuccess(:final data):
            if (kDebugMode) print('[RideSession] Ride details fetched OK: ${data.id}, pickup=${data.pickupAddress}, status=${data.status}');
            _showRideRequest(data, timeoutSeconds);
            break;
          case ApiFailure(:final exception):
            if (kDebugMode) print('[RideSession] getRideDetails FAILED: $exception — trying socket data as Ride');
            // Try to parse the socket data itself as a Ride (backend may embed ride fields)
            _showRideRequest(
              _buildFallbackRide(socketData, rideId, distanceKm, etaMinutes),
              timeoutSeconds,
            );
        }
      } catch (e) {
        if (kDebugMode) print('[RideSession] getRideDetails EXCEPTION: $e — using fallback');
        _showRideRequest(
          _buildFallbackRide(socketData, rideId, distanceKm, etaMinutes),
          timeoutSeconds,
        );
      }
    });
    _destinationChangeSub = _socketService.onDestinationChange.listen((data) {
      _ref.read(destinationChangeRequestProvider.notifier).state = data;
    });

    // Persistent listener for incoming chat messages from riders.
    // This ensures messages are captured even when the chat screen is not open,
    // mirroring the user app's ActiveRideNotifier pattern.
    _chatSub = _socketService.onChatMessage.listen((data) {
      if (!mounted) return;
      final senderRole = data['senderRole'] as String? ?? '';
      // Ignore own (driver) messages — already added as optimistic local msg
      if (senderRole == 'DRIVER') return;

      final ride = state;
      if (ride == null) return;

      // Handle timestamp: backend sends epoch ms (int) or ISO string
      final rawTs = data['timestamp'];
      DateTime ts;
      if (rawTs is int) {
        ts = DateTime.fromMillisecondsSinceEpoch(rawTs);
      } else if (rawTs is String) {
        ts = DateTime.tryParse(rawTs) ?? DateTime.now();
      } else {
        ts = DateTime.now();
      }

      final msg = ChatMessage(
        id: (data['id'] ?? '').toString(),
        message: data['message'] as String? ?? '',
        senderId: data['senderId'] as String? ?? '',
        isDriver: false,
        timestamp: ts,
      );

      _ref.read(chatMessagesProvider.notifier).addIncomingMessage(msg);
    });

    // Listen for ride status changes (e.g. user-initiated cancellation)
    _statusChangeSub = _socketService.onRideStatusChanged.listen((data) {
      if (!mounted) return;
      final status = data['status'] as String? ?? '';
      final rideId = data['rideId'] as String?;
      final currentRide = state;

      // Only process if it's for our current ride
      if (currentRide == null) return;
      if (rideId != null && rideId != currentRide.id) return;

      if (kDebugMode) print('[RideSession] Status changed via socket: status=$status, rideId=$rideId');

      if (status == 'CANCELLED') {
        _cancelCountdown();
        state = null;
        _driverStatusNotifier.goOnline();
        if (kDebugMode) print('[RideSession] Ride cancelled by user — cleared ride state');
      }
    });
  }

  /// Show an incoming ride request and start the countdown.
  void _showRideRequest(Ride ride, int timeoutSeconds) {
    if (kDebugMode) print('[RideSession] Showing ride request UI: ${ride.id}, timeout=${timeoutSeconds}s');
    state = ride;
    _startCountdown(timeoutSeconds);
  }

  /// Build a Ride from socket data when the API call fails.
  /// The socket event may contain full ride fields or just minimal data.
  Ride _buildFallbackRide(Map<String, dynamic> socketData, String rideId,
      double distanceKm, int etaMinutes) {
    // If the socket data has pickupAddress, it likely contains full ride info
    if (socketData.containsKey('pickupAddress') || socketData.containsKey('pickup_address')) {
      try {
        return Ride.fromJson({...socketData, 'id': rideId});
      } catch (e) {
        if (kDebugMode) print('[RideSession] Failed to parse socket data as Ride: $e');
      }
    }
    // Minimal fallback
    return Ride(
      id: rideId,
      status: RideStatus.requested,
      rider: const RiderInfo(id: '', firstName: 'Rider', lastName: '', phone: '', rating: 0),
      pickupAddress: socketData['pickupAddress'] as String? ?? socketData['pickup_address'] as String? ?? 'Pickup location',
      pickupLat: 0,
      pickupLng: 0,
      dropoffAddress: socketData['dropoffAddress'] as String? ?? socketData['dropoff_address'] as String? ?? 'Dropoff location',
      dropoffLat: 0,
      dropoffLng: 0,
      fare: 0,
      distanceKm: distanceKm,
      estimatedMinutes: etaMinutes,
      createdAt: DateTime.now(),
    );
  }

  /// Accept the current ride request.
  /// Returns true if accepted successfully, false if the ride is no longer available.
  Future<bool> acceptRide() async {
    final ride = state;
    if (ride == null) {
      if (kDebugMode) print('[RideSession] acceptRide: no active ride request');
      return false;
    }
    if (kDebugMode) print('[RideSession] acceptRide: accepting ride ${ride.id}');
    _cancelCountdown();
    try {
      final result = await _repository.acceptRide(ride.id);
      switch (result) {
        case ApiSuccess(:final data):
          if (kDebugMode) print('[RideSession] acceptRide SUCCESS: status=${data.status}');
          // Auto-transition to EN_ROUTE after accepting
          state = ride.copyWith(status: RideStatus.driverEnRoute);
          _driverStatusNotifier.setOnRide();
          // Fire en-route call to backend (fire-and-forget)
          _repository.markEnRoute(ride.id).then((_) {
            if (kDebugMode) print('[RideSession] en-route marked successfully');
          }).catchError((e) {
            if (kDebugMode) print('[RideSession] en-route call failed: $e');
          });
          // Join the ride room on WebSocket
          _socketService.joinRide(ride.id);
          return true;
        case ApiFailure(:final exception):
          if (kDebugMode) print('[RideSession] acceptRide FAILED: $exception — trying respond endpoint');
          // Fallback: use the respond endpoint with accepted: true
          try {
            final respondResult = await _repository.respondToRide(ride.id, accepted: true);
            switch (respondResult) {
              case ApiSuccess():
                if (kDebugMode) print('[RideSession] acceptRide via respond endpoint succeeded');
                state = ride.copyWith(status: RideStatus.driverEnRoute);
                _driverStatusNotifier.setOnRide();
                // Fire en-route call to backend (fire-and-forget)
                _repository.markEnRoute(ride.id).then((_) {
                  if (kDebugMode) print('[RideSession] en-route marked successfully');
                }).catchError((e) {
                  if (kDebugMode) print('[RideSession] en-route call failed: $e');
                });
                _socketService.joinRide(ride.id);
                return true;
              case ApiFailure(:final exception):
                if (kDebugMode) print('[RideSession] acceptRide respond fallback also failed: $exception');
                // Ride is no longer available — clear state and go back to online
                state = null;
                _driverStatusNotifier.goOnline();
                return false;
            }
          } catch (e) {
            if (kDebugMode) print('[RideSession] acceptRide respond fallback exception: $e');
            state = null;
            _driverStatusNotifier.goOnline();
            return false;
          }
      }
    } catch (e) {
      if (kDebugMode) print('[RideSession] acceptRide EXCEPTION: $e');
      state = null;
      _driverStatusNotifier.goOnline();
      return false;
    }
  }

  /// Skip / decline the current ride request.
  void skipRide() {
    final ride = state;
    _cancelCountdown();
    state = null;
    // Notify backend of decline (fire-and-forget)
    if (ride != null) {
      _repository.respondToRide(ride.id, accepted: false).then((_) {
        if (kDebugMode) print('[RideSession] Decline sent for ${ride.id}');
      }).catchError((_) {});
    }
  }

  /// Mark as arriving at pickup location.
  Future<bool> markAsArriving() async {
    final ride = state;
    if (ride == null) return false;
    final result = await _repository.arriveAtPickup(ride.id);
    return switch (result) {
      ApiSuccess(:final data) => () {
          // Preserve original ride data — only update status
          state = ride.copyWith(status: data.status);
          return true;
        }(),
      ApiFailure() => false,
    };
  }

  /// Start ride after OTP verification.
  Future<bool> startRide(String otp) async {
    final ride = state;
    if (ride == null) return false;
    final result = await _repository.startRide(ride.id, otp: otp);
    return switch (result) {
      ApiSuccess(:final data) => () {
          // Preserve original ride data — only update status
          state = ride.copyWith(status: data.status);
          return true;
        }(),
      ApiFailure() => false,
    };
  }

  /// Advance to the next stop in a multi-stop ride.
  Future<bool> nextStop() async {
    final ride = state;
    if (ride == null || !ride.hasStops) return false;

    // Mark current stop as completed and advance index
    final updatedStops = List<RideStop>.from(ride.stops);
    if (ride.currentStopIndex < updatedStops.length) {
      updatedStops[ride.currentStopIndex] =
          updatedStops[ride.currentStopIndex].copyWith(completed: true);
    }

    final nextIndex = ride.currentStopIndex + 1;

    final result = await _repository.nextStop(ride.id);
    return switch (result) {
      ApiSuccess() => () {
          state = ride.copyWith(
            stops: updatedStops,
            currentStopIndex: nextIndex,
          );
          return true;
        }(),
      ApiFailure() => false,
    };
  }

  /// End the active ride.
  Future<bool> endRide() async {
    final ride = state;
    if (ride == null) return false;
    final result = await _repository.completeRide(ride.id);
    return switch (result) {
      ApiSuccess(:final data) => () {
          _ref.read(rideSummaryProvider.notifier).state = data;
          _ref.read(showCollectAmountProvider.notifier).state =
              data.paymentMethod.toLowerCase() == 'cash';
          state = ride.copyWith(status: RideStatus.completed);
          return true;
        }(),
      ApiFailure() => false,
    };
  }

  /// Cancel ride with a reason.
  Future<bool> cancelRide(String reason) async {
    final ride = state;
    if (ride == null) return false;
    final result = await _repository.cancelRide(ride.id, reason: reason);
    return switch (result) {
      ApiSuccess() => () {
          _socketService.leaveRide(ride.id);
          state = null;
          _driverStatusNotifier.goOnline();
          _socketService.reconnect();
          return true;
        }(),
      ApiFailure() => false,
    };
  }

  /// Dismiss collect amount screen and show ride summary.
  void dismissCollectAmount() {
    _ref.read(showCollectAmountProvider.notifier).state = false;
  }

  /// Rate the rider after ride completion.
  Future<void> rateRider(int rating, {String? comment}) async {
    final ride = state;
    if (ride == null) return;
    try {
      await _repository.rateRider(ride.id, rating: rating, comment: comment);
    } catch (_) {
      // Rating failure is non-blocking
    }
  }

  /// Report rider as no-show.
  Future<bool> reportNoShow() async {
    final ride = state;
    if (ride == null) return false;
    final result = await _repository.reportNoShow(ride.id);
    return switch (result) {
      ApiSuccess() => () {
          state = null;
          _driverStatusNotifier.goOnline();
          return true;
        }(),
      ApiFailure() => false,
    };
  }

  /// Respond to a destination change request from the rider.
  void respondToDestinationChange(bool accepted) {
    final ride = state;
    if (ride == null) return;

    // Read the pending request data before clearing it
    final requestData = _ref.read(destinationChangeRequestProvider);
    final changeRequestId = requestData?['changeRequestId'] as String? ??
        requestData?['id'] as String? ?? '';

    _socketService.respondToDestinationChange(ride.id, changeRequestId, accepted);
    _ref.read(destinationChangeRequestProvider.notifier).state = null;

    // If accepted, update the ride state with new destination so map/polyline updates
    if (accepted && requestData != null) {
      final newAddress = requestData['newDropoffAddress'] as String?;
      final newLat = (requestData['newDropoffLat'] as num?)?.toDouble();
      final newLng = (requestData['newDropoffLng'] as num?)?.toDouble();
      final newFare = (requestData['newEstimatedFare'] as num?)?.toDouble();

      state = ride.copyWith(
        dropoffAddress: newAddress ?? ride.dropoffAddress,
        dropoffLat: newLat ?? ride.dropoffLat,
        dropoffLng: newLng ?? ride.dropoffLng,
        fare: newFare ?? ride.fare,
      );
      if (kDebugMode) print('[RideSession] Destination changed: address=$newAddress, lat=$newLat, lng=$newLng, fare=$newFare');
    }
  }

  /// Called after the driver dismisses the ride summary.
  void finishRide() {
    // Leave the ride room before clearing state
    final rideId = state?.id;
    if (rideId != null && rideId.isNotEmpty) {
      _socketService.leaveRide(rideId);
    }
    state = null;
    _ref.read(rideSummaryProvider.notifier).state = null;
    _ref.read(showCollectAmountProvider.notifier).state = false;
    _driverStatusNotifier.goOnline();
    // Reconnect socket to ensure driver is visible for new ride requests
    _socketService.reconnect();
    // Refresh the today-earnings pill on the home screen
    _ref.read(todayEarningsProvider.notifier).fetchTodayEarnings();
  }

  void _startCountdown(int seconds) {
    _ref.read(rideRequestMaxCountdownProvider.notifier).state = seconds;
    _ref.read(rideRequestCountdownProvider.notifier).state = seconds;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = _ref.read(rideRequestCountdownProvider);
      if (current <= 1) {
        timer.cancel();
        skipRide();
      } else {
        _ref.read(rideRequestCountdownProvider.notifier).state = current - 1;
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _ref.read(rideRequestCountdownProvider.notifier).state = 0;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _rideRequestSub?.cancel();
    _destinationChangeSub?.cancel();
    _chatSub?.cancel();
    _statusChangeSub?.cancel();
    super.dispose();
  }
}
