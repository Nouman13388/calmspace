class Message {
  final int id;
  final int userId;
  final int therapistId;
  final String message;
  final DateTime createdAt;
  final bool isSentByUser; // Hidden variable to distinguish sender

  Message({
    required this.id,
    required this.userId,
    required this.therapistId,
    required this.message,
    required this.createdAt,
    required this.isSentByUser,
  });

  factory Message.fromJson(Map<String, dynamic> json, int currentUserId) {
    return Message(
      id: json['id'],
      userId: json['user'],
      therapistId: json['therapist'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      isSentByUser: json['user'] == currentUserId, // Set based on user ID
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'therapist': therapistId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      // 'isSentByUser' is not included in the toJson as it's only for UI use
    };
  }
}
