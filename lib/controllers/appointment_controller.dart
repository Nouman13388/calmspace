import 'package:get/get.dart';
import 'package:http/http.dart' as http; // For future API calls
import 'dart:convert'; // For JSON encoding/decoding
import '../constants/app_constants.dart';
import '../models/dashboard_model.dart';

class AppointmentController extends GetxController {
  RxList<Appointment> appointments = <Appointment>[].obs;

  // Fetching data from the API (Django backend)
  Future<void> fetchAppointments(String role, String name) async {
    // Using the AppConstants for the base URL
    var url = Uri.parse('${AppConstants.appointmentsUrl}$role/$name');
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
        id: 1, // Sample ID
        status: "Upcoming",
        startTime: DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
        endTime: DateTime.now().add(const Duration(hours: 3)).toIso8601String(),
        therapist: 'Sample Therapist', // Provide a sample therapist name
        user: 'Sample User', // Provide a sample user name
      ),
      Appointment(
        id: 2, // Sample ID
        status: "Completed",
        startTime: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        endTime: DateTime.now().toIso8601String(),
        therapist: 'Sample Therapist', // Provide a sample therapist name
        user: 'Sample User', // Provide a sample user name
      ),
    ];
  }

  // Mark appointment as completed
  void completeAppointment(Appointment appointment) {
    int index = appointments.indexOf(appointment);
    if (index != -1) {
      appointments[index] = Appointment(
        id: appointment.id, // Retaining the original ID
        status: "Completed",
        startTime: appointment.startTime,
        endTime: appointment.endTime,
        therapist: appointment.therapist, // Retain the therapist
        user: appointment.user, // Retain the user
      );
    }
  }
}
