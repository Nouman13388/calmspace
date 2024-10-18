class EndUser {
  String? email; // Nullable
  String? name; // Nullable
  DateTime? createdAt; // Nullable
  DateTime? updatedAt; // Nullable

  EndUser({
    this.email,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create a User from JSON
  factory EndUser.fromJson(Map<String, dynamic> json) {
    return EndUser(
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

  // Method to convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
