class DeliveryChatMessage {
  const DeliveryChatMessage({
    required this.id,
    required this.deliveryId,
    required this.message,
    required this.sentByPartner,
    required this.sentAt,
  });

  final String id;
  final String deliveryId;
  final String message;
  final bool sentByPartner;
  final DateTime sentAt;

  factory DeliveryChatMessage.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawTimestamp = json['timestamp'];

    final sentAt = switch (rawTimestamp) {
      int value => DateTime.fromMillisecondsSinceEpoch(value),
      String value => DateTime.tryParse(value) ?? DateTime.now(),
      _ => DateTime.now(),
    };

    final senderRole = json['senderRole']?.toString().toUpperCase();

    return DeliveryChatMessage(
      id: json['id']?.toString() ?? '',
      deliveryId: json['deliveryId']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      sentByPartner: json['sentByPartner'] == true || senderRole == 'PARTNER',
      sentAt: sentAt,
    );
  }
}
