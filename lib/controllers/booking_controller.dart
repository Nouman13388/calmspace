import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/api_service.dart'; // Assuming ApiService is responsible for fetching appointment data

class BookingController extends GetxController {
  // Observable variables to store selected times
  var selectedStartDateTime = Rx<DateTime?>(null);
  var selectedEndDateTime = Rx<DateTime?>(null);
  var isLoading = RxBool(false);
  var isAppointmentBooked = RxBool(false);

  // Assume API service is initialized here
  final ApiService _apiService = Get.find<ApiService>();

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
      // Proceed with booking logic here

      // Simulate a delay (e.g., API call)
      await Future.delayed(Duration(seconds: 2));

      // After booking, mark appointment as successfully booked
      isAppointmentBooked.value = true;
      isLoading.value = false;

      // Optionally: Show success notification
      Get.snackbar('Booking Successful', 'Your appointment has been booked.');
    } catch (error) {
      print("Error occurred while booking: $error");
      isLoading.value = false;
      Get.snackbar('Booking Failed',
          'Failed to book your appointment. Please try again.');
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
