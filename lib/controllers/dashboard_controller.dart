import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dashboard_model.dart';
import '../services/api_service.dart';

class DashboardController extends GetxController {
  final ApiService apiService = ApiService();
  var healthDataList = <HealthData>[].obs;
  var appointmentList = <Appointment>[].obs;

  var points = 0.obs;
  var badge = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData(); // Consolidated loading method
  }

  // New consolidated method to load all dashboard data
  Future<void> loadDashboardData() async {
    await loadStoredData(); // Load points and badge
    await fetchHealthData(); // Load health data
    await fetchAppointments('userRole', 'userName'); // Load appointments
  }

  // Load points and badge from SharedPreferences
  Future<void> loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      points.value = prefs.getInt('assessment_points') ?? 0;
      badge.value = prefs.getString('assessment_badge') ?? '';
      debugPrint(
          "Stored data loaded: points = ${points.value}, badge = '${badge.value}'"); // Debugging
    } catch (e) {
      debugPrint("Error loading stored data: $e"); // Debugging
    }
  }

  // Fetch health data from API
  Future<void> fetchHealthData() async {
    try {
      healthDataList.value = await apiService.fetchHealthData();
      debugPrint(
          "Health data fetched: ${healthDataList.length} entries"); // Debugging
    } catch (e) {
      debugPrint(
          "Error fetching health data: $e"); // Error handling, no Snackbar
    }
  }

  // Fetch appointments from API
  Future<void> fetchAppointments(String role, String name) async {
    try {
      appointmentList.value = await apiService.fetchAppointments(role, name);
      debugPrint(
          "Appointments fetched: ${appointmentList.length} entries"); // Debugging
    } catch (e) {
      debugPrint(
          "Error fetching appointments: $e"); // Error handling, no Snackbar
    }
  }

  // Update health data based on assessment results
  void updateHealthData(String mood, String symptoms) {
    final newHealthData = HealthData(
      id: healthDataList.length + 1,
      mood: mood,
      symptoms: symptoms,
      createdAt: DateTime.now(),
    );
    healthDataList.add(newHealthData);
    debugPrint(
        "Health data updated: Mood = $mood, Symptoms = $symptoms"); // Debugging
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
