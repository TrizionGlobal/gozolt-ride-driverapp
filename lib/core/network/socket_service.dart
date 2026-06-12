import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/api_constants.dart';

void _log(String msg) {
  if (kDebugMode) print(msg);
}

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

class SocketService {
  io.Socket? _socket;
  String? _token;

  final _onRideRequestController = StreamController<Map<String, dynamic>>.broadcast();
  final _onRideStatusChangedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _onSurgeUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _onChatMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _onDestinationChangeController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _onPaymentChangedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onRideRequest => _onRideRequestController.stream;
  Stream<Map<String, dynamic>> get onRideStatusChanged =>
      _onRideStatusChangedController.stream;
  Stream<Map<String, dynamic>> get onSurgeUpdate =>
      _onSurgeUpdateController.stream;
  Stream<Map<String, dynamic>> get onChatMessage =>
      _onChatMessageController.stream;
  Stream<Map<String, dynamic>> get onDestinationChange =>
      _onDestinationChangeController.stream;
  Stream<Map<String, dynamic>> get onPaymentChanged =>
      _onPaymentChangedController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    _token = token;
    _disconnect();

    final baseUrl = ApiConstants.baseUrl.replaceAll('/v1', '');
    final url = '$baseUrl/drivers';
    _log('[DriverSocket] Attempting connection to: $url');

    _socket = io.io(
      '$baseUrl/drivers',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .setReconnectionAttempts(999999)
          .build(),
    );

    _socket!.onConnect((_) {
      _log('[DriverSocket] CONNECTED to /drivers namespace');
    });

    _socket!.onConnectError((error) {
      _log('[DriverSocket] CONNECTION ERROR: $error');
    });

    _socket!.onError((error) {
      _log('[DriverSocket] ERROR: $error');
    });

    _socket!.on('connected', (data) {
      _log('[DriverSocket] Server confirmed connection: $data');
    });

    _socket!.on('error', (data) {
      _log('[DriverSocket] Server error: $data');
    });

    _socket!.on('ride:request:new', (data) {
      _log('[DriverSocket] New ride request received');
      if (data is Map<String, dynamic>) {
        _onRideRequestController.add(data);
      } else if (data is Map) {
        _onRideRequestController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('ride:accepted', (data) {
      _log('[DriverSocket] Ride accepted confirmed');
      if (data is Map<String, dynamic>) {
        _onRideStatusChangedController.add({...data, 'status': 'ACCEPTED'});
      }
    });

    _socket!.on('ride:status:changed', (data) {
      _log('[DriverSocket] Ride status changed');
      if (data is Map<String, dynamic>) {
        _onRideStatusChangedController.add(data);
      }
    });

    _socket!.on('surge:update', (data) {
      _log('[DriverSocket] Surge update');
      if (data is Map<String, dynamic>) {
        _onSurgeUpdateController.add(data);
      }
    });

    _socket!.on('chat:message', (data) {
      _log('[DriverSocket] Chat message received');
      if (data is Map<String, dynamic>) {
        _onChatMessageController.add(data);
      } else if (data is Map) {
        _onChatMessageController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('ride:destination_change_request', (data) {
      _log('[DriverSocket] Destination change request');
      if (data is Map<String, dynamic>) {
        _onDestinationChangeController.add(data);
      } else if (data is Map) {
        _onDestinationChangeController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('ride:payment:changed', (data) {
      _log('[DriverSocket] Payment changed');
      if (data is Map<String, dynamic>) {
        _onPaymentChangedController.add(data);
      } else if (data is Map) {
        _onPaymentChangedController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.onDisconnect((reason) {
      _log('[DriverSocket] Disconnected: $reason');
    });

    _socket!.onReconnect((_) {
      _log('[DriverSocket] Reconnected to /drivers namespace');
    });

    _socket!.onReconnectAttempt((_) {
      _log('[DriverSocket] Attempting to reconnect...');
    });

    _socket!.connect();
  }

  void _disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  void disconnect() {
    _log('[DriverSocket] Manually disconnecting');
    _disconnect();
  }

  void reconnect() {
    if (_token != null) {
      _log('[DriverSocket] Reconnecting with saved token');
      connect(_token!);
    }
  }

  void emitLocationUpdate(double lat, double lng, double heading, double speed) {
    _socket?.emit('driver:location:update', {
      'lat': lat,
      'lng': lng,
      'heading': heading,
      'speed': speed,
    });
  }

  void joinRide(String rideId) {
    _socket?.emit('ride:join', {'rideId': rideId});
  }

  void leaveRide(String rideId) {
    _socket?.emit('ride:leave', {'rideId': rideId});
  }

  void sendChatMessage(String rideId, String message) {
    _socket?.emit('chat:send', {
      'rideId': rideId,
      'message': message,
    });
  }

  void respondToDestinationChange(String rideId, String changeRequestId, bool accepted) {
    _socket?.emit('ride:destination_change_response', {
      'rideId': rideId,
      'changeRequestId': changeRequestId,
      'accepted': accepted,
    });
  }

  void dispose() {
    _disconnect();
    _onRideRequestController.close();
    _onRideStatusChangedController.close();
    _onSurgeUpdateController.close();
    _onChatMessageController.close();
    _onDestinationChangeController.close();
    _onPaymentChangedController.close();
  }
}
