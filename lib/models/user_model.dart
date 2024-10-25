class EndUser {
  int? id; // Add this field
  String? email; // Nullable
  String? name; // Nullable
  DateTime? createdAt; // Nullable
  DateTime? updatedAt; // Nullable

  EndUser({
    this.id,
    this.email,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create a EndUser from JSON
  factory EndUser.fromJson(Map<String, dynamic> json) {
    return EndUser(
      id: json['id'], // Parse id from JSON
      email: json['email'],
      name: json['name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Method to convert EndUser to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include id in JSON
      'email': email,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
