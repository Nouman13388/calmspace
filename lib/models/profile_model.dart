class Profile {
  final int id;
  final String user;
  final String email; // Add email field
  final String bio;
  final String location;
  final String profilePicture;
  final String privacySettings;
  final DateTime createdAt; // Use DateTime for createdAt
  final DateTime updatedAt; // Use DateTime for updatedAt

  Profile({
    required this.id,
    required this.user,
    required this.email, // email should be passed in constructor
    required this.bio,
    required this.location,
    required this.profilePicture,
    required this.privacySettings,
    required this.createdAt,
    required this.updatedAt,
  });

  // Deserialize the JSON response
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      user: json['user'],
      email: json['email'], // Parse email
      bio: json['bio'],
      location: json['location'],
      profilePicture: json['profile_picture'],
      privacySettings: json['privacy_settings'],
      createdAt: DateTime.parse(json['created_at']), // Convert to DateTime
      updatedAt: DateTime.parse(json['updated_at']), // Convert to DateTime
    );
  }

  // Serialize the profile object to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'email': email, // Include email in the toJson method
      'bio': bio,
      'location': location,
      'profile_picture': profilePicture,
      'privacy_settings': privacySettings,
      'created_at': createdAt.toIso8601String(), // Convert DateTime to String
      'updated_at': updatedAt.toIso8601String(), // Convert DateTime to String
    };
  }
}
