import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/socket_service.dart';
import '../../data/models/chat_message.dart';

final chatMessagesProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return ChatNotifier(socketService: socketService);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final SocketService _socketService;
  StreamSubscription<Map<String, dynamic>>? _chatSub;

  ChatNotifier({required SocketService socketService})
      : _socketService = socketService,
        super([]) {
    _chatSub = _socketService.onChatMessage.listen(_onMessage);
  }

  void _onMessage(Map<String, dynamic> data) {
    // Ignore own messages to prevent duplicates (already added optimistic local msg)
    final senderRole = data['senderRole'] as String? ?? '';
    if (senderRole == 'DRIVER') return;

    final msg = ChatMessage.fromJson(data);
    // Deduplicate: skip if message with same id already exists
    if (msg.id.isNotEmpty && state.any((m) => m.id == msg.id)) return;
    state = [...state, msg];
  }

  /// Add an incoming message from a persistent listener (e.g. RideSessionNotifier).
  /// Deduplicates by message id to avoid showing the same message twice.
  void addIncomingMessage(ChatMessage message) {
    if (message.id.isNotEmpty && state.any((m) => m.id == message.id)) return;
    state = [...state, message];
  }

  void sendMessage(String rideId, String message) {
    final localMsg = ChatMessage(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      senderId: 'driver',
      isDriver: true,
      timestamp: DateTime.now(),
    );
    state = [...state, localMsg];
    _socketService.sendChatMessage(rideId, message);
  }

  void clearMessages() {
    state = [];
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    super.dispose();
  }
}
