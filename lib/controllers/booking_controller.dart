import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';

class BookingController extends GetxController {
  // Observable variables to store selected times
  var selectedStartDateTime = Rx<DateTime?>(null);
  var selectedEndDateTime = Rx<DateTime?>(null);
  var isLoading = RxBool(false);
  var isAppointmentBooked = RxBool(false);
  var errorMessage = RxString('');
  var successMessage = RxString('');

  final ApiService _apiService = Get.find<ApiService>();

  // Clear previous messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  // Set error message
  void setErrorMessage(String message) {
    errorMessage.value = message;
    print('Debug: Error message set - $message');
  }

  // Set success message
  void setSuccessMessage(String message) {
    successMessage.value = message;
    print('Debug: Success message set - $message');
  }

  // Check if the appointment overlaps with any existing appointment
  Future<bool> checkForOverlappingAppointments(
      int userId, int therapistId) async {
    try {
      print('Debug: Checking for overlapping appointments...');
      final appointmentsJson = await _apiService.fetchAppointments(
          userId.toString(), therapistId.toString());

      // Fix: Cast the data correctly to a List of Appointment objects
      List<Appointment> appointments = (appointmentsJson as List)
          .map((appointmentJson) =>
              Appointment.fromJson(Map<String, dynamic>.from(appointmentJson)))
          .toList();

      DateTime? start = selectedStartDateTime.value;
      DateTime? end = selectedEndDateTime.value;

      if (start == null || end == null) {
        print('Debug: Start or end time is null.');
        return false;
      }

      // Check for overlapping appointments
      for (var appointment in appointments) {
        print(
            'Debug: Checking appointment: ${appointment.startTime} to ${appointment.endTime}');
        if (start.isBefore(appointment.endTime) &&
            end.isAfter(appointment.startTime)) {
          print('Debug: Appointment overlaps with existing appointment.');
          return true; // There is an overlap
        }
      }
      print('Debug: No overlap found.');
      return false; // No overlap
    } catch (e) {
      print("Error checking appointments: $e");
      return false; // In case of error, assume no overlap
    }
  }

  // Booking the appointment
  Future<void> bookAppointment(int userId, int therapistId, String userEmail,
      String therapistEmail) async {
    isLoading.value = true;
    try {
      DateTime? start = selectedStartDateTime.value;
      DateTime? end = selectedEndDateTime.value;

      if (start == null || end == null) {
        setErrorMessage("Please select valid start and end times.");
        isLoading.value = false;
        return;
      }

      if (end.isBefore(start)) {
        setErrorMessage("End time cannot be earlier than start time.");
        isLoading.value = false;
        return;
      }

      if (start.isBefore(DateTime.now())) {
        setErrorMessage("You cannot book an appointment in the past.");
        isLoading.value = false;
        return;
      }

      print('Debug: Selected start time - $start');
      print('Debug: Selected end time - $end');

      bool isOverlapping =
          await checkForOverlappingAppointments(userId, therapistId);

      if (isOverlapping) {
        setErrorMessage(
            "The selected time overlaps with an existing appointment.");
        isLoading.value = false;
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

      print('Debug: Sending POST request to $url with data: $appointmentData');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(appointmentData),
      );

      print('Debug: Response status code - ${response.statusCode}');
      if (response.statusCode == 201) {
        setSuccessMessage("Appointment booked successfully.");
        isAppointmentBooked.value = true;
      } else {
        print('Debug: Response body - ${response.body}');
        setErrorMessage("Failed to book appointment: ${response.body}");
      }

      isLoading.value = false;
    } catch (error) {
      print("Error occurred while booking: $error");
      isLoading.value = false;
      setErrorMessage(
          'An error occurred while booking your appointment. Please try again.');
    }
  }

  // Select the start date/time and automatically set end time to 1.5 hours later
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
      print('Debug: Start time selected - $dateTime');

      // Automatically set the end time to 1.5 hours after the start time
      setEndTimeForStartTime();
    } else {
      selectedEndDateTime.value = dateTime;
      print('Debug: End time selected - $dateTime');
    }
  }

  // Set end time to 1.5 hours after the selected start time
  void setEndTimeForStartTime() {
    if (selectedStartDateTime.value != null) {
      final startTime = selectedStartDateTime.value!;
      final endTime = startTime.add(Duration(hours: 1, minutes: 30));
      selectedEndDateTime.value = endTime;
      print('Debug: Automatically setting end time to $endTime');
    }
  }
}
