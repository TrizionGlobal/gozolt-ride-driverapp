class ChatMessage {
  final String id;
  final String message;
  final String senderId;
  final bool isDriver;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.message,
    required this.senderId,
    required this.isDriver,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Derive isDriver from senderRole (backend sends 'USER' or 'DRIVER')
    final senderRole = json['senderRole'] as String? ?? '';
    final isDriverMsg = json['isDriver'] == true || senderRole == 'DRIVER';

    // Handle timestamp: backend sends epoch ms (int), but could also be String
    DateTime ts;
    final rawTs = json['timestamp'];
    if (rawTs is int) {
      ts = DateTime.fromMillisecondsSinceEpoch(rawTs);
    } else if (rawTs is String) {
      ts = DateTime.tryParse(rawTs) ?? DateTime.now();
    } else {
      ts = DateTime.now();
    }

    return ChatMessage(
      id: (json['id'] ?? '').toString(),
      message: json['message'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      isDriver: isDriverMsg,
      timestamp: ts,
    );
  }
}
