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

  factory HealthData.fromMap(Map<String, dynamic> json) {
    return HealthData(
      id: json['id'],
      mood: json['mood'],
      symptoms: json['symptoms'],
      createdAt: DateTime.parse(json['created_at']), // Parse the date
    );
  }
}

class Appointment {
  final int id;
  final String status;
  final String startTime;
  final String endTime;
  final String therapist; // Add this field
  final String user; // Add this field

  Appointment({
    required this.id,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.therapist, // Include in constructor
    required this.user, // Include in constructor
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      status: json['status'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      therapist: json['therapist'], // Assuming your API returns this
      user: json['user'], // Assuming your API returns this
    );
  }
}
