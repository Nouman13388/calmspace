import 'dart:convert'; // For JSON encoding/decoding

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // For future API calls

import '../constants/app_constants.dart';
import '../models/dashboard_model.dart';

class AppointmentController extends GetxController {
  RxList<Appointment> appointments = <Appointment>[].obs;

  // Fetching data from the API (Django backend)
  Future<void> fetchAppointments(String role, String name) async {
    var url = Uri.parse('${AppConstants.appointmentsUrl}$role/$name');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        appointments.value =
            (data as List).map((json) => Appointment.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print('Failed to fetch appointments: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching appointments: $e");
      }
    }
  }

  // Fetch appointments for a specific date
  Future<void> fetchAppointmentsForDate(
      String therapistName, DateTime date) async {
    var formattedDate =
        date.toIso8601String().split('T')[0]; // Format date to YYYY-MM-DD
    var url = Uri.parse(
        '${AppConstants.appointmentsUrl}date/$therapistName/$formattedDate'); // Adjust endpoint as needed

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        appointments.value =
            (data as List).map((json) => Appointment.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print(
              'Failed to fetch appointments for the date: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching appointments for the date: $e");
      }
    }
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
