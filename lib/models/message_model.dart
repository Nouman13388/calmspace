class Message {
  final int id;
  final int userId;
  final int therapistId;
  final String message;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.userId,
    required this.therapistId,
    required this.message,
    required this.createdAt,
  });

  // Factory method to create a Message from a JSON response
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      userId: json['user'],
      therapistId: json['therapist'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Method to convert the Message object to a Map (for sending POST/PUT requests)
  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'therapist': therapistId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
