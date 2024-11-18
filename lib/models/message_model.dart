class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final DateTime createdAt;
  final bool isSentByUser;
  final String senderName;
  final String receiverName;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
    required this.isSentByUser,
    required this.senderName,
    required this.receiverName,
  });

  // Modify the fromJson method to handle nullable fields safely
  factory Message.fromJson(Map<String, dynamic> json, int userId) {
    // Determine the sender and receiver names if not provided
    String senderName = json['sender_name'] ?? 'Unknown';
    String receiverName = json['receiver_name'] ?? 'Unknown';

    // If the current user is the sender, show 'You' as the sender name
    if (json['sender_id'] == userId) {
      senderName = 'You';
    }

    // If the current user is the receiver, show 'You' as the receiver name
    if (json['receiver_id'] == userId) {
      receiverName = 'You';
    }

    return Message(
      id: json['id'] ?? 0, // Use default 0 if id is missing
      senderId: json['sender_id'] ?? 0, // Default to 0 if sender_id is missing
      receiverId:
          json['receiver_id'] ?? 0, // Default to 0 if receiver_id is missing
      message: json['message'] ??
          '', // Default to empty string if message is missing
      createdAt: DateTime.parse(json['created_at'] ??
          DateTime.now()
              .toIso8601String()), // Default to now if created_at is missing
      isSentByUser: json['sender_id'] ==
          userId, // Assuming the current user is the sender
      senderName: senderName, // Use the correctly determined sender name
      receiverName: receiverName, // Use the correctly determined receiver name
    );
  }

  // Convert the message object to JSON for sending to the server
  Map<String, dynamic> toJson() {
    return {
      'user': senderId, // Add user field
      'therapist': receiverId, // Add therapist field
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'sender_name': senderName,
      'receiver_name': receiverName,
    };
  }
}
