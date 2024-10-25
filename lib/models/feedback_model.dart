class Feedback {
  final int? id; // Make this nullable
  final String message;
  final DateTime createdAt;
  final int? user; // Make this nullable

  Feedback({
    this.id,
    required this.message,
    required this.createdAt,
    this.user,
  });

  // Factory method for creating a Feedback instance from JSON
  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'],
    );
  }

  // Method to convert a Feedback instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'user': user, // This can be null
    };
  }
}
