import 'package:get/get.dart';
import '../models/appointment_model.dart';
import 'package:http/http.dart' as http; // For future API calls
import 'dart:convert'; // For JSON encoding/decoding

class AppointmentController extends GetxController {
  RxList<Appointment> appointments = <Appointment>[].obs;

  // Simulating fetching data from an API (Django backend)
  Future<void> fetchAppointments(String role, String name) async {
    // Replace with your API endpoint
    var url = Uri.parse('https://your-django-api.com/appointments/$role/$name');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        appointments.value = (data as List)
            .map((json) => Appointment.fromJson(json))
            .toList();
      }
    } catch (e) {
      print("Error fetching appointments: $e");
    }
  }

  // For local testing, simulating appointments
  void addSampleAppointments() {
    appointments.value = [
      Appointment(
        user: "User A",
        therapist: "Therapist 1",
        date: DateTime.now().add(const Duration(hours: 2)),
        status: "Upcoming",
      ),
      Appointment(
        user: "User B",
        therapist: "Therapist 2",
        date: DateTime.now().subtract(const Duration(hours: 1)),
        status: "Completed",
      ),
    ];
  }

  // Mark appointment as completed
  void completeAppointment(Appointment appointment) {
    int index = appointments.indexOf(appointment);
    if (index != -1) {
      appointments[index] = Appointment(
        user: appointment.user,
        therapist: appointment.therapist,
        date: appointment.date,
        status: "Completed",
      );
    }
  }
}
