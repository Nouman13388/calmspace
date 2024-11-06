import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For formatting date and time

import '../../constants/app_constants.dart';

class BookingController extends GetxController {
  // Rx variables to store selected date/time and the appointment status
  Rx<DateTime?> selectedStartDateTime = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDateTime = Rx<DateTime?>(null);

  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
  final DateFormat timeFormatter = DateFormat('HH:mm');

  // Method to pick the date and time for start and end
  void selectDateTime(
      bool isStartTime, DateTime pickedDate, TimeOfDay pickedTime) {
    if (isStartTime) {
      selectedStartDateTime.value = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    } else {
      selectedEndDateTime.value = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    }
  }

  // API call to book the appointment
  Future<void> bookAppointment(int userId, int therapistId, String userEmail,
      String therapistEmail) async {
    if (selectedStartDateTime.value != null &&
        selectedEndDateTime.value != null) {
      final appointment = {
        'start_time': selectedStartDateTime.value!.toIso8601String(),
        'end_time': selectedEndDateTime.value!.toIso8601String(),
        'status': 'User', // Assuming status is 'User' by default
        'user': userId, // Pass only the user ID here
        'therapist': therapistId, // Pass only the therapist ID here
      };

      // Debugging: print the appointment data
      print('Booking Appointment with data:');
      print('Start Time: ${selectedStartDateTime.value}');
      print('End Time: ${selectedEndDateTime.value}');
      print('User ID: $userId, User Email: $userEmail');
      print('Therapist ID: $therapistId, Therapist Email: $therapistEmail');

      final response = await http.post(
        Uri.parse(AppConstants.appointmentsUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(appointment),
      );

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        print('Appointment successfully booked.');
        Get.snackbar(
          'Appointment Booked',
          'Your appointment with therapist is confirmed.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      } else {
        print('Failed to book appointment. Error: ${response.body}');
        Get.snackbar(
          'Error',
          'Failed to book appointment. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      print('Error: Start and End times are not selected.');
      Get.snackbar('Error', 'Please select both start and end times.');
    }
  }
}
