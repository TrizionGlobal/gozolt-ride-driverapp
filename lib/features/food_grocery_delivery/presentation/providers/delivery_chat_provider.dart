import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/delivery_chat_message.dart';

class DeliveryChatState {
  const DeliveryChatState({
    this.messages = const <DeliveryChatMessage>[],
    this.isSending = false,
    this.errorMessage,
  });

  final List<DeliveryChatMessage> messages;
  final bool isSending;
  final String? errorMessage;

  DeliveryChatState copyWith({
    List<DeliveryChatMessage>? messages,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeliveryChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class DeliveryChatNotifier extends StateNotifier<DeliveryChatState> {
  DeliveryChatNotifier(
    this.deliveryId,
  ) : super(
          const DeliveryChatState(),
        );

  final String deliveryId;

  Future<bool> sendMessage(String value) async {
    final message = value.trim();

    if (message.isEmpty || state.isSending) {
      return false;
    }

    state = state.copyWith(
      isSending: true,
      clearError: true,
    );

    // TODO(FOOD_GROCERY_CHAT_API):
    // Replace this temporary delay with the delivery-chat endpoint or
    // socket event. The backend must authorize the assigned partner
    // against this delivery ID before accepting the message.
    await Future<void>.delayed(
      const Duration(milliseconds: 250),
    );

    final localMessage = DeliveryChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      deliveryId: deliveryId,
      message: message,
      sentByPartner: true,
      sentAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: List<DeliveryChatMessage>.unmodifiable(
        <DeliveryChatMessage>[
          ...state.messages,
          localMessage,
        ],
      ),
      isSending: false,
      clearError: true,
    );

    return true;
  }

  void addIncomingMessage(
    DeliveryChatMessage message,
  ) {
    if (message.deliveryId != deliveryId) {
      return;
    }

    final duplicate = message.id.isNotEmpty &&
        state.messages.any(
          (existingMessage) => existingMessage.id == message.id,
        );

    if (duplicate) {
      return;
    }

    state = state.copyWith(
      messages: List<DeliveryChatMessage>.unmodifiable(
        <DeliveryChatMessage>[
          ...state.messages,
          message,
        ],
      ),
      clearError: true,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      isSending: false,
      errorMessage: message,
    );
  }

  void clearMessages() {
    state = const DeliveryChatState();
  }
}

final deliveryChatProvider = StateNotifierProvider.autoDispose
    .family<DeliveryChatNotifier, DeliveryChatState, String>(
  (ref, deliveryId) {
    return DeliveryChatNotifier(
      deliveryId,
    );
  },
);
