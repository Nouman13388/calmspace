import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/api_service.dart'; // Assuming ApiService is responsible for fetching appointment data

class BookingController extends GetxController {
  // Observable variables to store selected times
  var selectedStartDateTime = Rx<DateTime?>(null);
  var selectedEndDateTime = Rx<DateTime?>(null);
  var isLoading = RxBool(false);
  var isAppointmentBooked = RxBool(false);
  var errorMessage = RxString('');
  var successMessage = RxString('');

  // Assume API service is initialized here
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
      // Fetch existing appointments for the given user and therapist
      final appointments = await _apiService.fetchAppointments(
          userId.toString(), therapistId.toString());

      // Check for overlap with selected start and end times
      DateTime? start = selectedStartDateTime.value;
      DateTime? end = selectedEndDateTime.value;

      if (start == null || end == null) return false;

      // Check for overlap with any existing appointments
      for (var appointment in appointments) {
        if (start.isBefore(appointment.endTime) &&
            end.isAfter(appointment.startTime)) {
          // There is an overlap
          return true;
        }
      }
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
      // Get the selected start and end time
      DateTime? start = selectedStartDateTime.value;
      DateTime? end = selectedEndDateTime.value;

      if (start == null || end == null) {
        setErrorMessage("Please select valid start and end times.");
        isLoading.value = false;
        return;
      }

      // Check if the appointment overlaps
      bool isOverlapping = await checkForOverlappingAppointments(userId, therapistId);

      if (isOverlapping) {
        setErrorMessage("The selected time overlaps with an existing appointment.");
        isLoading.value = false;
        return;
      }

      // Proceed with booking the appointment on the backend
      final appointmentData = {
        'user': userId,
        'therapist': therapistId,
        'start_time': start.toIso8601String(),
        'end_time': end.toIso8601String(),
        'status': 'User',  // Adjust the status as needed
      };

      final url = 'http://50.19.24.133:8000/api/appointments/';  // Use AppConstants.appointmentsUrl if you have this constant

      // Make POST request to backend to book the appointment
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(appointmentData),
      );

      // Handle the response
      if (response.statusCode == 201) {
        setSuccessMessage("Appointment booked successfully.");
        isAppointmentBooked.value = true;
      } else {
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

  // Select the start and end date/time
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
    } else {
      selectedEndDateTime.value = dateTime;
    }
  }
}
