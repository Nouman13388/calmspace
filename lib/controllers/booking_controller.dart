import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../constants/app_constants.dart';

class BookingController extends GetxController {
  Rx<DateTime?> selectedStartDateTime = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDateTime = Rx<DateTime?>(null);
  RxBool isLoading = false.obs; // Observable to track loading state

  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
  final DateFormat timeFormatter = DateFormat('HH:mm');

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
      print('Selected Start DateTime: ${selectedStartDateTime.value}');
    } else {
      selectedEndDateTime.value = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      print('Selected End DateTime: ${selectedEndDateTime.value}');
    }
  }

  Future<void> bookAppointment(int userId, int therapistId, String userEmail,
      String therapistEmail) async {
    if (selectedStartDateTime.value != null &&
        selectedEndDateTime.value != null) {
      isLoading.value = true; // Start loading indicator
      final appointment = {
        'start_time': selectedStartDateTime.value!.toIso8601String(),
        'end_time': selectedEndDateTime.value!.toIso8601String(),
        'status': 'User',
        'user': userId,
        'therapist': therapistId,
      };

      print('Booking Appointment with the following data:');
      print('User ID: $userId, User Email: $userEmail');
      print('Therapist ID: $therapistId, Therapist Email: $therapistEmail');
      print('Start Time: ${appointment['start_time']}');
      print('End Time: ${appointment['end_time']}');

      try {
        final response = await http.post(
          Uri.parse(AppConstants.appointmentsUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(appointment),
        );

        print('API Response Code: ${response.statusCode}');
        print('API Response Body: ${response.body}');

        if (response.statusCode == 201) {
          // Only show this snackbar upon successful booking
          Get.snackbar(
            'Appointment Booked',
            'Your appointment has been successfully booked.',
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 2),
          );

          await Future.delayed(
              Duration(seconds: 2)); // Delay to allow snackbar to display
          Get.back();
        } else {
          print(
              'Failed to book appointment. Status Code: ${response.statusCode}');
          _showErrorSnackbar(
              'Failed to book appointment. Please try again later.');
        }
      } catch (e) {
        print('Exception occurred during booking: $e');
        _showErrorSnackbar('An unexpected error occurred.');
      } finally {
        isLoading.value = false; // Stop loading indicator
        print('Booking process completed.');
      }
    } else {
      print('Error: Start and/or End times not selected.');
      _showErrorSnackbar('Please select both start and end times.');
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }
}
