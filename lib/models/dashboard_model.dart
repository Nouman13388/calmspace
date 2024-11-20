import 'package:intl/intl.dart';

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
  final int therapist;
  final int user;

  Appointment({
    required this.id,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.therapist,
    required this.user,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Define the date format you're receiving in the API response
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");

    return Appointment(
      id: json['id'],
      status: json['status'] ?? 'unknown', // Default value if null
      startTime: json['start_time'] != null
          ? dateFormat.parse(json['start_time'])
          : DateTime.now(), // Parse DateTime using custom format
      endTime: json['end_time'] != null
          ? dateFormat.parse(json['end_time'])
          : DateTime.now(), // Parse DateTime using custom format
      therapist: json['therapist'] ?? 0, // Default value if null
      user: json['user'] ?? 0, // Default value if null
    );
  }

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
