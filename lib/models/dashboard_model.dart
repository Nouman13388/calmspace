class HealthData {
  final int id;
  final String mood;
  final String symptoms;
  final DateTime createdAt; // New field

  HealthData({
    required this.id,
    required this.mood,
    required this.symptoms,
    required this.createdAt, // Include in constructor
  });

  // Modify to use fromMap to keep the consistency
  factory HealthData.fromMap(Map<String, dynamic> json) {
    return HealthData(
      id: json['id'],
      mood: json['mood'],
      symptoms: json['symptoms'],
      createdAt: DateTime.parse(json['created_at']), // Parse the date
    );
  }

  // Optional toJson method to convert to a map if needed
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood,
      'symptoms': symptoms,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Appointment {
  final int id;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final int therapist; // Changed to int
  final int user; // Changed to int

  Appointment({
    required this.id,
    required this.status,
    required this.startTime, // DateTime
    required this.endTime, // DateTime
    required this.therapist, // Include as int
    required this.user, // Include as int
  });

  // Modify to handle null values gracefully and match your requirements
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      status: json['status'] ?? 'unknown', // Default value if null
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : DateTime.now(), // Parse DateTime
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : DateTime.now(), // Parse DateTime
      therapist: json['therapist'] ?? 0, // Corrected field name
      user: json['user'] ?? 0, // Default value if null
    );
  }

  // Optional toJson method if you need to send the appointment data back to an API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'start_time': startTime.toIso8601String(), // Convert DateTime to string
      'end_time': endTime.toIso8601String(), // Convert DateTime to string
      'therapist': therapist,
      'user': user,
    };
  }
}
