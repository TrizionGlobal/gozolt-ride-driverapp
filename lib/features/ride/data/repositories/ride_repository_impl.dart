import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/repositories/ride_repository.dart';
import '../datasources/ride_remote_datasource.dart';
import '../models/ride.dart';
import '../models/ride_detail.dart';
import '../models/ride_history_item.dart';
import '../models/ride_status.dart';
import '../models/ride_stop.dart';
import '../models/ride_summary.dart';
import '../models/rider_info.dart';

class RideRepositoryImpl implements RideRepository {
  final RideRemoteDataSource _remoteDataSource;

  static const _devBypass = false;

  static const _dummyRider = RiderInfo(
    id: 'rider-001',
    firstName: 'Maria',
    lastName: 'Vella',
    avatarUrl: null,
    phone: '+35679987654',
    rating: 4.5,
  );

  static final _dummyRide = Ride(
    id: 'ride-uuid-001',
    status: RideStatus.requested,
    rider: _dummyRider,
    pickupAddress: '14, Republic Street, Valletta VLT 1110',
    pickupLat: 35.8989,
    pickupLng: 14.5146,
    dropoffAddress: '25, Tower Road, Sliema SLM 1605',
    dropoffLat: 35.9125,
    dropoffLng: 14.5014,
    fare: 12.50,
    distanceKm: 4.5,
    estimatedMinutes: 25,
    otp: '4829',
    paymentMethod: 'cash',
    createdAt: DateTime(2026, 2, 19, 10, 30),
    stops: const [
      RideStop(
        id: 'stop-001',
        address: '10, St. Anne Street, Floriana FRN 1011',
        lat: 35.8948,
        lng: 14.5093,
      ),
      RideStop(
        id: 'stop-002',
        address: '5, The Strand, Gzira GZR 1027',
        lat: 35.9060,
        lng: 14.4940,
      ),
    ],
  );

  static final _dummyHistoryItems = [
    RideHistoryItem(
      id: 'ride-h-001',
      status: 'COMPLETED',
      pickupAddress: '14, Republic Street, Valletta',
      dropoffAddress: '25, Tower Road, Sliema',
      paymentMethod: 'cash',
      fare: 12.50,
      tipAmount: 2.50,
      completedAt: DateTime(2026, 2, 19, 11, 45),
      createdAt: DateTime(2026, 2, 19, 10, 30),
    ),
    RideHistoryItem(
      id: 'ride-h-002',
      status: 'COMPLETED',
      pickupAddress: '8, Triq il-Kbira, Mosta',
      dropoffAddress: '3, Spinola Bay, St Julians',
      paymentMethod: 'card',
      fare: 18.75,
      tipAmount: 3.00,
      completedAt: DateTime(2026, 2, 18, 16, 20),
      createdAt: DateTime(2026, 2, 18, 15, 40),
    ),
    RideHistoryItem(
      id: 'ride-h-003',
      status: 'COMPLETED',
      pickupAddress: '1, Freedom Square, Vittoriosa',
      dropoffAddress: '12, Tigne Point, Sliema',
      paymentMethod: 'cash',
      fare: 22.00,
      completedAt: DateTime(2026, 2, 18, 12, 10),
      createdAt: DateTime(2026, 2, 18, 11, 25),
    ),
    RideHistoryItem(
      id: 'ride-h-004',
      status: 'CANCELLED',
      pickupAddress: '5, Bay Street, Paceville',
      dropoffAddress: '9, Mdina Gate, Mdina',
      paymentMethod: 'card',
      fare: null,
      completedAt: null,
      createdAt: DateTime(2026, 2, 17, 22, 15),
    ),
    RideHistoryItem(
      id: 'ride-h-005',
      status: 'COMPLETED',
      pickupAddress: '20, Merchants Street, Valletta',
      dropoffAddress: '7, Balluta Bay, St Julians',
      paymentMethod: 'cash',
      fare: 15.30,
      completedAt: DateTime(2026, 2, 17, 14, 55),
      createdAt: DateTime(2026, 2, 17, 14, 10),
    ),
  ];

  static final _dummyRideDetail = RideDetail(
    id: 'ride-h-001',
    status: 'COMPLETED',
    pickupAddress: '14, Republic Street, Valletta VLT 1110',
    pickupLat: 35.8989,
    pickupLng: 14.5146,
    dropoffAddress: '25, Tower Road, Sliema SLM 1605',
    dropoffLat: 35.9125,
    dropoffLng: 14.5014,
    baseFare: 3.50,
    distanceFare: 5.40,
    timeFare: 2.10,
    waitTimeFee: 1.50,
    totalFare: 12.50,
    distanceKm: 4.5,
    durationMinutes: 18,
    paymentMethod: 'cash',
    paymentStatus: 'PAID',
    requestedAt: DateTime(2026, 2, 19, 10, 30),
    acceptedAt: DateTime(2026, 2, 19, 10, 31),
    arrivedAt: DateTime(2026, 2, 19, 10, 38),
    startedAt: DateTime(2026, 2, 19, 10, 40),
    completedAt: DateTime(2026, 2, 19, 11, 45),
    stops: const [
      RideStop(
        id: 'stop-001',
        address: '10, St. Anne Street, Floriana FRN 1011',
        lat: 35.8948,
        lng: 14.5093,
      ),
    ],
    tipAmount: 2.50,
  );

  static const _dummySummary = RideSummary(
    rideId: 'ride-uuid-001',
    baseFare: 3.50,
    distanceFare: 5.40,
    timeFare: 2.10,
    totalFare: 12.50,
    driverEarnings: 10.00,
    distanceKm: 4.5,
    durationMinutes: 18,
    paymentMethod: 'cash',
    tipAmount: 2.50,
    bookingFee: 1.50,
    surgeMultiplier: 1.2,
  );

  RideRepositoryImpl({required RideRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<ApiResult<Ride>> getActiveRide() async {
    if (_devBypass) return ApiSuccess(_dummyRide);

    try {
      final ride = await _remoteDataSource.getActiveRide();
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride?>> getDriverActiveRide() async {
    if (_devBypass) return const ApiSuccess(null);

    try {
      final ride = await _remoteDataSource.getDriverActiveRide();
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride>> getRideDetails(String rideId) async {
    if (_devBypass) return ApiSuccess(_dummyRide);

    try {
      final ride = await _remoteDataSource.getRideDetails(rideId);
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride>> acceptRide(String rideId) async {
    if (_devBypass) {
      return ApiSuccess(_dummyRide.copyWith(status: RideStatus.driverEnRoute));
    }

    try {
      final ride = await _remoteDataSource.acceptRide(rideId);
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride>> arriveAtPickup(String rideId) async {
    if (_devBypass) {
      return ApiSuccess(
          _dummyRide.copyWith(status: RideStatus.driverArrived));
    }

    try {
      final ride = await _remoteDataSource.arriveAtPickup(rideId);
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride>> startRide(String rideId,
      {required String otp}) async {
    if (_devBypass) {
      return ApiSuccess(_dummyRide.copyWith(status: RideStatus.inProgress));
    }

    try {
      final ride = await _remoteDataSource.startRide(rideId, otp: otp);
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<RideSummary>> completeRide(String rideId) async {
    if (_devBypass) return const ApiSuccess(_dummySummary);

    try {
      final summary = await _remoteDataSource.completeRide(rideId);
      return ApiSuccess(summary);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> respondToRide(String rideId,
      {required bool accepted}) async {
    if (_devBypass) return const ApiSuccess(null);

    try {
      await _remoteDataSource.respondToRide(rideId, accepted: accepted);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> cancelRide(String rideId,
      {required String reason}) async {
    if (_devBypass) return const ApiSuccess(null);

    try {
      await _remoteDataSource.cancelRide(rideId, reason: reason);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride>> nextStop(String rideId) async {
    if (_devBypass) {
      return ApiSuccess(_dummyRide.copyWith(status: RideStatus.inProgress));
    }

    try {
      final ride = await _remoteDataSource.nextStop(rideId);
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<List<RideHistoryItem>>> getRideHistory({
    int page = 1,
    int limit = 20,
  }) async {
    if (_devBypass) return ApiSuccess(_dummyHistoryItems);

    try {
      final items = await _remoteDataSource.getRideHistory(
        page: page,
        limit: limit,
      );
      return ApiSuccess(items);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<RideDetail>> getRideDetail(String rideId) async {
    if (_devBypass) return ApiSuccess(_dummyRideDetail);

    try {
      final detail = await _remoteDataSource.getRideDetail(rideId);
      return ApiSuccess(detail);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> rateRider(String rideId, {required int rating, String? comment}) async {
    if (_devBypass) return const ApiSuccess(null);
    try {
      await _remoteDataSource.rateRider(rideId, rating: rating, comment: comment);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<Ride>> markEnRoute(String rideId) async {
    if (_devBypass) {
      return ApiSuccess(_dummyRide.copyWith(status: RideStatus.driverEnRoute));
    }
    try {
      final ride = await _remoteDataSource.markEnRoute(rideId);
      return ApiSuccess(ride);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }

  @override
  Future<ApiResult<void>> reportNoShow(String rideId) async {
    if (_devBypass) return const ApiSuccess(null);
    try {
      await _remoteDataSource.reportNoShow(rideId);
      return const ApiSuccess(null);
    } on ApiException catch (e) {
      return ApiFailure(e);
    }
  }
}
