import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get_connect/connect.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/assessment_question.dart';
import '../models/content.dart';
import '../models/dashboard_model.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart';

class ApiService {
  // Fetch health data
  Future<List<HealthData>> fetchHealthData() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.healthDataUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => HealthData.fromMap(data)).toList();
      } else {
        debugPrint(
            "Failed to load health data: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load health data');
      }
    } catch (e) {
      debugPrint("Error fetching health data: $e");
      throw Exception('Error fetching health data: $e');
    }
  }

  // Fetch appointments
  Future<List<Appointment>> fetchAppointments(String role, String name) async {
    try {
      final response = await http.get(Uri.parse(AppConstants.appointmentsUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => Appointment.fromJson(data)).toList();
      } else {
        debugPrint(
            "Failed to load appointments: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      debugPrint("Error fetching appointments: $e");
      throw Exception('Error fetching appointments: $e');
    }
  }

  // Get user by email
  Future<EndUser?> getUserByEmail(String email) async {
    try {
      final response =
          await http.get(Uri.parse('${AppConstants.userUrl}?email=$email'));

      if (response.statusCode == 200) {
        return EndUser.fromJson(json.decode(response.body)); // Use EndUser here
      } else {
        throw Exception('Failed to fetch user data: ${response.body}');
      }
    } catch (e) {
      debugPrint("Error fetching user by email: $e");
      return null;
    }
  }

  // Get all feedback
  Future<List<Feedback>?> getAllFeedback() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.feedbackUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        // Map JSON data to a list of Feedback objects
        return jsonData.map((data) => Feedback.fromJson(data)).toList();
      } else {
        debugPrint('Failed to load feedback: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching feedback: $e');
      return null;
    }
  }

  // Submit feedback
  Future<bool> submitFeedback(Feedback feedback) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.feedbackUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(feedback.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
            'Error submitting feedback: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Something went wrong while submitting feedback: $e');
    }
    return false;
  }

  Future<List<AssessmentQuestion>> fetchAssessmentQuestions() async {
    final response = await http.get(Uri.parse(AppConstants.assessmentsUrl));

    if (response.statusCode == 200) {
      // Assuming your backend returns a list of assessment questions in JSON format
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => AssessmentQuestion.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load assessment questions');
    }
  }
}

class ContentService extends GetConnect {
  // Fetch content from ArticleUrl
  Future<List<MentalHealthContent>> fetchContentFromArticle() async {
    final response = await get(AppConstants.articlesUrl);

    if (response.statusCode == 200) {
      final List<dynamic> contentList = response.body[0]
          ['content']; // Ensure this structure matches your API response
      return contentList
          .map((data) => MentalHealthContent.fromMap(data))
          .toList();
    } else {
      debugPrint(
          "Failed to load articles: ${response.statusCode} - ${response.body}");
      throw Exception('Failed to load articles');
    }
  }

  Future<EndUser?> getUserByEmail(String email) async {
    try {
      final response =
          await http.get(Uri.parse('${AppConstants.usersUrl}?email=$email'));
      if (response.statusCode == 200) {
        List<dynamic> users = jsonDecode(response.body);
        if (users.isNotEmpty) {
          return EndUser.fromJson(
              users[0]); // Assuming the first match is the user
        }
      } else {
        print(
            'Error fetching user by email: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception fetching user by email: $e');
    }
    return null;
  }

  // Get all feedback
  Future<List<Feedback>?> getAllFeedback() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.feedbackUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        // Map JSON data to a list of Feedback objects
        return jsonData.map((data) => Feedback.fromJson(data)).toList();
      } else {
        print('Failed to load feedback: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching feedback: $e');
      return null;
    }
  }

  // Submit feedback
  Future<bool> submitFeedback(Feedback feedback) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.feedbackUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(feedback.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error submitting feedback: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Something went wrong while submitting feedback: $e');
    }
    return false;
  }
}
