import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/connect.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/content.dart';
import '../models/dashboard_model.dart';

class ApiService {
  Future<List<HealthData>> fetchHealthData() async {
    final response = await http.get(Uri.parse(AppConstants.healthDataUrl));
    // if (kDebugMode) {
    //   print("Fetched HealthData: ${response.body}");
    // }
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => HealthData.fromMap(data)).toList();
    } else {
      throw Exception('Failed to load health data');
    }
  }

  Future<List<Appointment>> fetchAppointments(String role, String name) async {
    try {
      final response = await http.get(Uri.parse(AppConstants.appointmentsUrl));

      // Debug: Print the URL being accessed
      if (kDebugMode) {
        print("Fetching Appointments from: ${AppConstants.appointmentsUrl}");
      }

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        if (kDebugMode) {
          print("Fetched Appointments: $jsonData");
        }
        return jsonData.map((data) => Appointment.fromJson(data)).toList();
      } else {
        // Debug: Print status code and response body for troubleshooting
        if (kDebugMode) {
          print("Failed to load appointments: ${response.statusCode} - ${response.body}");
        }
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      // Handle and print any exceptions
      if (kDebugMode) {
        print("Error fetching appointments: $e");
      }
      throw Exception('Error fetching appointments: $e');
    }
  }


}


class ContentService extends GetConnect {
  // Fetch content from ArticleUrl
  Future<List<MentalHealthContent>> fetchContentFromArticle() async {
    final response = await get(AppConstants.articlesUrl);
    if (response.statusCode == 200) {
      final jsonResponse = response.body[0]; // Get the first element
      final List<dynamic> contentList = jsonResponse['content']; // Extract the content list
      return contentList
          .map((data) => MentalHealthContent.fromMap(data))
          .toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }
}