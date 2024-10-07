class Appointment {
  final String user;
  final String therapist;
  final DateTime date;
  final String status; // Upcoming, Completed, etc.

  Appointment({
    required this.user,
    required this.therapist,
    required this.date,
    required this.status,
  });

  // Factory method for easy backend integration (Django + MySQL)
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      user: json['user'],
      therapist: json['therapist'],
      date: DateTime.parse(json['date']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'therapist': therapist,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
