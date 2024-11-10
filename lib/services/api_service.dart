import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../controllers/user_controller.dart';
import '../models/assessment_question.dart';
import '../models/content.dart';
import '../models/dashboard_model.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart';

class ApiService {
  final UserController _userController = Get.find<UserController>();

  // Generic method to fetch data from any endpoint
  Future<List<T>> _fetchData<T>(
      String url, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        debugPrint("Fetched data: $jsonData");
        return jsonData.map((data) => fromJson(data)).toList();
      } else {
        debugPrint(
            "Failed to fetch data: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      throw Exception('Error fetching data: $e');
    }
  }

  // Check if the user is logged in, throw an error if not
  Future<int> _checkUserLoggedIn() async {
    final userId = await _userController.getLoggedInUserId();
    if (userId == null) {
      throw Exception('User is not logged in. Please log in to continue.');
    }
    return userId;
  }

  // Fetch health data for the logged-in user
  Future<List<HealthData>> fetchHealthData() async {
    final userId = await _checkUserLoggedIn();
    final url = '${AppConstants.healthDataUrl}?user_id=$userId';
    return _fetchData(url, (data) => HealthData.fromMap(data));
  }

  // Fetch appointments for the logged-in user and therapist
  Future<List<Appointment>> fetchAppointments(String role, String name) async {
    final userId = await _checkUserLoggedIn();
    final url =
        '${AppConstants.appointmentsUrl}?user_id=$userId&role=$role&name=$name';
    return _fetchData(url, (data) => Appointment.fromJson(data));
  }

  // Get user by email
  Future<EndUser?> getUserByEmail(String email) async {
    try {
      final response =
          await http.get(Uri.parse('${AppConstants.userUrl}?email=$email'));

      if (response.statusCode == 200) {
        debugPrint("Fetched user data: ${response.body}");
        return EndUser.fromJson(json.decode(response.body));
      } else {
        debugPrint("Failed to fetch user data: ${response.body}");
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
        debugPrint("Fetched feedback data: $jsonData");
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
        debugPrint("Feedback submitted successfully.");
        return true;
      } else {
        debugPrint(
            'Error submitting feedback: ${response.statusCode} - ${response.body}');
        throw Exception('Error submitting feedback');
      }
    } catch (e) {
      debugPrint('Something went wrong while submitting feedback: $e');
      throw Exception('Feedback submission failed');
    }
  }

  // Fetch assessment questions
  Future<List<AssessmentQuestion>> fetchAssessmentQuestions() async {
    final response = await http.get(Uri.parse(AppConstants.assessmentsUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      debugPrint("Fetched assessment questions: $jsonData");
      return jsonData.map((item) => AssessmentQuestion.fromJson(item)).toList();
    } else {
      debugPrint('Failed to load assessment questions');
      throw Exception('Failed to load assessment questions');
    }
  }
}

class ContentService extends GetConnect {
  // Fetch content from ArticleUrl
  Future<List<MentalHealthContent>> fetchContentFromArticle() async {
    try {
      // Send a GET request to the articles URL
      final response = await http.get(Uri.parse(AppConstants.articlesUrl));

      if (response.statusCode == 200) {
        // Parse the response body, which is a list of articles
        final List<dynamic> responseData = json.decode(response.body);

        // Extract the 'content' field from the response (it contains the list of articles)
        final List<dynamic> articlesData = responseData[0]['content'];

        // Log the fetched articles for debugging
        debugPrint("Fetched articles: $articlesData");

        // Map the list of articles data to MentalHealthContent objects
        return articlesData
            .map((data) => MentalHealthContent.fromMap(data))
            .toList();
      } else {
        // Handle non-200 status codes
        debugPrint(
            "Failed to load articles: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      // Catch any exceptions and print the error
      debugPrint("Error fetching article content: $e");
      throw Exception('Error fetching article content');
    }
  }

  // Get user by email (for ContentService)
  Future<EndUser?> getUserByEmail(String email) async {
    try {
      final response =
          await http.get(Uri.parse('${AppConstants.usersUrl}?email=$email'));
      if (response.statusCode == 200) {
        List<dynamic> users = jsonDecode(response.body);
        if (users.isNotEmpty) {
          debugPrint("Fetched user by email: ${users[0]}");
          return EndUser.fromJson(
              users[0]); // Assuming the first match is the user
        }
      } else {
        debugPrint(
            'Error fetching user by email: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception fetching user by email: $e');
    }
    return null;
  }

  // Get all feedback
  Future<List<Feedback>?> getAllFeedback() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.feedbackUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        debugPrint("Fetched feedback data: $jsonData");

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
        debugPrint("Feedback submitted successfully.");
        return true;
      } else {
        debugPrint(
            'Error submitting feedback: ${response.statusCode} - ${response.body}');
        throw Exception('Error submitting feedback');
      }
    } catch (e) {
      debugPrint('Something went wrong while submitting feedback: $e');
      throw Exception('Feedback submission failed');
    }
  }
}
