import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/dashboard_model.dart';
import '../services/api_service.dart';

class DashboardController extends GetxController {
  final ApiService apiService = ApiService();
  var healthDataList = <HealthData>[].obs;
  var appointmentList = <Appointment>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHealthData();
    fetchAppointments(
        'userRole', 'userName'); // Replace with actual role and name
  }

  Future<void> fetchHealthData() async {
    try {
      healthDataList.value = await apiService.fetchHealthData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load health data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchAppointments(String role, String name) async {
    try {
      appointmentList.value = await apiService.fetchAppointments(role, name);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load appointments: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  // New method to update health data based on assessment results
  void updateHealthData(String mood, String symptoms) {
    final newHealthData = HealthData(
      id: healthDataList.length + 1, // Temporary ID, should be unique
      mood: mood,
      symptoms: symptoms,
      createdAt: DateTime.now(), // Record the current timestamp
    );

    // Add the new health data entry to the list
    healthDataList.add(newHealthData);
  }

  // Helper method to convert health data into chart data
  List<List<double>> getChartData() {
    return healthDataList.map((data) {
      return [data.id.toDouble(), moodToValue(data.mood)];
    }).toList();
  }

  // Helper method to convert mood to chart value
  double moodToValue(String mood) {
    switch (mood) {
      case "Happy":
        return 5.0;
      case "Anxious":
        return 3.0;
      case "Sad":
        return 1.0;
      default:
        return 0.0;
    }
  }
}
