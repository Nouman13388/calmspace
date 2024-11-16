class Tip {
  final int userId; // Add userId field
  final String userEmail;
  final String type;
  final String result;

  // Constructor
  Tip({
    required this.userId,
    required this.userEmail,
    required this.type,
    required this.result,
  });

  // Factory constructor for creating a Tip instance from a JSON map
  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      userId: json['userId'], // Parse userId
      userEmail: json['userEmail'],
      type: json['type'],
      result: json['result'],
    );
  }

  // Method to convert the Tip instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId, // Add userId to JSON map
      'userEmail': userEmail,
      'type': type,
      'result': result,
    };
  }
}
