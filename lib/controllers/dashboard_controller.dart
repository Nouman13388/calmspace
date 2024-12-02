import 'package:calmspace/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    loadDashboardData(); // Load all dashboard data on initialization
  }

  // Load all the data (points, badge, health data, and appointments)
  Future<void> loadDashboardData() async {
    try {
      await loadStoredData(); // Load points and badge
      await Future.wait(
          [fetchHealthData(), fetchAppointments('userRole', 'userName')]);
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    }
  }

  // Load points and badge from SharedPreferences
  Future<void> loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userUid.isEmpty) {
        debugPrint("No logged-in user, cannot load stored data.");
        return;
      }

      // Use uid to create unique keys for the logged-in user
      points.value = prefs.getInt('${userUid}_assessment_points') ?? 0;
      badge.value = prefs.getString('${userUid}_assessment_badge') ?? '';

      debugPrint(
          "Stored data loaded: points = ${points.value}, badge = '${badge.value}'");
    } catch (e) {
      debugPrint("Error loading stored data: $e");
    }
  }

  // Save the updated points and badge to SharedPreferences
  Future<void> saveDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userUid.isEmpty) {
        debugPrint("No logged-in user, cannot save data.");
        return;
      }

      // Use uid to create unique keys for the logged-in user
      await prefs.setInt('${userUid}_assessment_points', points.value);
      await prefs.setString('${userUid}_assessment_badge', badge.value);
      debugPrint(
          "Dashboard data saved: points = ${points.value}, badge = '${badge.value}'");
    } catch (e) {
      debugPrint("Error saving dashboard data: $e");
    }
  }

  // Fetch health data from API
  Future<void> fetchHealthData() async {
    try {
      healthDataList.value = await apiService.fetchHealthData();
      debugPrint(
          "\n\n\nHealth data fetched: ${healthDataList.length} entries\n\n\n");
    } catch (e) {
      debugPrint("Error fetching health data: $e");
    }
  }

  Future<void> fetchAppointments(String role, String name) async {
    try {
      // Fetch logged-in user ID from the UserController
      final userId = await Get.find<UserController>().getLoggedInUserId();

      if (userId == null) {
        // If no user ID is found, handle the error
        debugPrint("No logged-in user found. Cannot fetch appointments.");
        return;
      }

      // Use the fetched user ID to request appointments
      var appointments = await apiService.fetchAppointments(userId);

      // Check if there are any appointments fetched
      if (appointments.isNotEmpty) {
        // Get the latest appointment (last item in the list)
        var latestAppointment = appointments.last;

        // Update the appointment list
        appointmentList.value = appointments;

        // Log the last appointment (latest one)
        debugPrint(
            "Latest Appointment: $latestAppointment"); // Will print a formatted string with all fields
      } else {
        debugPrint("No appointments found.");
      }
    } catch (e) {
      debugPrint("Error fetching appointments: $e");
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
    debugPrint("Health data updated: Mood = $mood, Symptoms = $symptoms");
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
