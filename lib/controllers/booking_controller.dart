import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';

class BookingController extends GetxController {
  var selectedStartDateTime = Rx<DateTime?>(null);
  var selectedEndDateTime = Rx<DateTime?>(null);
  var isLoading = RxBool(false);
  var isAppointmentBooked = RxBool(false);
  var errorMessage = RxString('');
  var successMessage = RxString('');

  final ApiService _apiService = Get.find<ApiService>();

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  void setErrorMessage(String message) {
    errorMessage.value = message;
    print('Error: $message');
  }

  void setSuccessMessage(String message) {
    successMessage.value = message;
    print('Success: $message');
  }

  Future<List<Appointment>> fetchAppointmentsFromApi(
      int userId, int therapistId) async {
    try {
      final url =
          "${AppConstants.appointmentsUrl}?user_id=$userId&therapist_id=$therapistId";
      print('Fetching appointments from: $url');

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print('Failed to fetch appointments: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  bool hasTimeConflict(
      DateTime start, DateTime end, List<Appointment> appointments) {
    for (var appointment in appointments) {
      if (start.isAtSameMomentAs(appointment.startTime) &&
          end.isAtSameMomentAs(appointment.endTime)) {
        return true;
      }
      if (start.isBefore(appointment.endTime) &&
          end.isAfter(appointment.startTime)) {
        return true;
      }
    }
    return false;
  }

  Future<bool> checkForOverlappingAppointments(
      int userId, int therapistId) async {
    try {
      final appointments = await fetchAppointmentsFromApi(userId, therapistId);
      final start = selectedStartDateTime.value;
      final end = selectedEndDateTime.value;

      if (start == null || end == null) {
        return false;
      }

      return hasTimeConflict(start, end, appointments);
    } catch (e) {
      print("Error checking for overlapping appointments: $e");
      return false;
    }
  }

  Future<void> bookAppointment(int userId, int therapistId, String userEmail,
      String therapistEmail) async {
    isLoading.value = true;
    try {
      final start = selectedStartDateTime.value;
      final end = selectedEndDateTime.value;

      if (start == null || end == null) {
        setErrorMessage("Please select valid start and end times.");
        return;
      }

      if (end.isBefore(start)) {
        setErrorMessage("End time cannot be earlier than start time.");
        return;
      }

      if (start.isBefore(DateTime.now())) {
        setErrorMessage("You cannot book an appointment in the past.");
        return;
      }

      final appointments = await fetchAppointmentsFromApi(userId, therapistId);

      if (hasTimeConflict(start, end, appointments)) {
        setErrorMessage(
            "The selected time conflicts with an existing appointment.");
        return;
      }

      final appointmentData = {
        'user': userId,
        'therapist': therapistId,
        'start_time': start.toIso8601String(),
        'end_time': end.toIso8601String(),
        'status': 'User',
      };

      final url = AppConstants.appointmentsUrl;
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(appointmentData),
      );

      if (response.statusCode == 201) {
        setSuccessMessage("Appointment booked successfully.");
        isAppointmentBooked.value = true;
      } else {
        setErrorMessage("Failed to book appointment: ${response.body}");
      }
    } catch (e) {
      setErrorMessage("Error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectDateTime(
      bool isStartTime, DateTime pickedDate, TimeOfDay pickedTime) {
    DateTime dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (isStartTime) {
      selectedStartDateTime.value = dateTime;
      setEndTimeForStartTime();
    } else {
      selectedEndDateTime.value = dateTime;
    }
  }

  void setEndTimeForStartTime() {
    if (selectedStartDateTime.value != null) {
      final startTime = selectedStartDateTime.value!;
      final endTime = startTime.add(const Duration(hours: 1, minutes: 30));
      selectedEndDateTime.value = endTime;
    }
  }
}
