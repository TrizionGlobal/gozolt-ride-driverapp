import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';

class DriverNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRead;

  const DriverNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  DriverNotification copyWith({bool? isRead}) {
    return DriverNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  factory DriverNotification.fromJson(Map<String, dynamic> json) {
    return DriverNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['body'] as String? ?? json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'SYSTEM',
      timestamp:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      isRead: json['read'] as bool? ?? false,
    );
  }
}

final notificationListProvider = StateNotifierProvider<
    NotificationListNotifier, AsyncValue<List<DriverNotification>>>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationListNotifier(dio);
});

class NotificationListNotifier
    extends StateNotifier<AsyncValue<List<DriverNotification>>> {
  final Dio _dio;

  NotificationListNotifier(this._dio) : super(const AsyncValue.loading()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get(
        '/users/me/notifications',
        queryParameters: {'page': 1, 'limit': 50},
      );
      final data = response.data;
      List<dynamic> items = [];
      if (data is Map<String, dynamic> && data['data'] is List) {
        items = data['data'] as List;
      } else if (data is List) {
        items = data;
      }
      final notifications = items
          .map((e) => DriverNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      state = AsyncValue.data(notifications);
    } catch (_) {
      // Return empty list on error instead of crashing
      state = const AsyncValue.data([]);
    }
  }

  void markAsRead(String id) {
    state.whenData((notifications) {
      state = AsyncValue.data([
        for (final n in notifications)
          if (n.id == id) n.copyWith(isRead: true) else n,
      ]);
    });
    // Fire and forget API call
    _dio.patch('/users/me/notifications/mark-read', data: {
      'notificationIds': [id],
    }).ignore();
  }

  void markAllAsRead() {
    state.whenData((notifications) {
      state = AsyncValue.data([
        for (final n in notifications) n.copyWith(isRead: true),
      ]);
    });
    _dio.patch('/users/me/notifications/mark-read', data: {
      'read': true,
    }).ignore();
  }

  void dismiss(String id) {
    state.whenData((notifications) {
      state = AsyncValue.data(notifications.where((n) => n.id != id).toList());
    });
  }
}
