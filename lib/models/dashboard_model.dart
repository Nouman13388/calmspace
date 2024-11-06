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
  final String startTime;
  final String endTime;
  final int therapist; // Changed to int
  final int user; // Changed to int

  Appointment({
    required this.id,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.therapist, // Include as int
    required this.user, // Include as int
  });

  // Modify to handle null values gracefully and match your requirements
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      status: json['status'] ?? 'unknown', // Default value if null
      startTime: json['start_time'] ?? '', // Default value if null
      endTime: json['end_time'] ?? '', // Default value if null
      therapist: json['professional'] ??
          0, // Changed to get the correct field and handle null
      user: json['user'] ?? 0, // Changed to handle null
    );
  }

  // Optional toJson method if you need to send the appointment data back to an API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'start_time': startTime,
      'end_time': endTime,
      'professional': therapist,
      'user': user,
    };
  }
}
