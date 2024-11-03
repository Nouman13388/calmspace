import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../controllers/dashboard_controller.dart';

class AssessmentController extends GetxController {
  var currentQuestionIndex = 0.obs;
  var selectedAnswers = <int, String>{}.obs;
  var isAssessmentComplete = false.obs;
  var mood = ''.obs; // Mood result
  var symptoms =
      "Based on assessment responses".obs; // Default symptoms message

  final questions = [
    {
      "question": "How are you feeling today?",
      "options": ["Good", "Okay", "Stressed", "Anxious"]
    },
    {
      "question": "How often do you feel relaxed?",
      "options": ["Always", "Often", "Sometimes", "Rarely"]
    },
    {
      "question": "Do you find it difficult to focus?",
      "options": ["Yes", "No"]
    },
  ];

  void evaluateAnswer(String answer) {
    selectedAnswers[currentQuestionIndex.value] = answer;

    if (currentQuestionIndex.value >= questions.length - 1) {
      print("Calculating results...");
      calculateResult();
      isAssessmentComplete(true);
      print("Assessment complete. Sending health data...");
      sendHealthData(); // Send data to backend after completion
    } else {
      currentQuestionIndex.value++;
      print("Moving to question ${currentQuestionIndex.value + 1}");
    }
  }

  void calculateResult() {
    int score = 0;

    for (var answer in selectedAnswers.values) {
      switch (answer) {
        case "Good":
        case "Always":
          score += 10;
          break;
        case "Okay":
        case "Often":
          score += 5;
          break;
        case "Stressed":
        case "Anxious":
        case "Sometimes":
          score += 3;
          break;
        case "Rarely":
        case "Yes":
          score += 1;
          break;
        case "No":
          score += 7;
          break;
      }
    }

    if (score >= 20) {
      mood("Happy");
    } else if (score >= 10) {
      mood("Anxious");
    } else {
      mood("Sad");
    }

    print("Calculated mood: ${mood.value}");

    final dashboardController = Get.find<DashboardController>();
    dashboardController.updateHealthData(mood.value, symptoms.value);
  }

  Future<int> getBackendUserId(String? email) async {
    if (email == null || email.isEmpty) {
      print("Email parameter is required to fetch user ID.");
      return 0; // Handle case where there's no Firebase user
    }

    final url = '${AppConstants.userUrl}?email=$email';
    print("Fetching backend user ID for email: $email");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("Fetched backend user ID: ${jsonResponse['id']}");
        return jsonResponse['id']; // Adjust according to your backend response
      } else {
        print('Failed to retrieve backend user ID: ${response.body}');
        return 0; // Or handle as appropriate
      }
    } catch (error) {
      print('Error fetching backend user ID: $error');
      return 0; // Handle error
    }
  }

  Future<void> sendHealthData() async {
    final url = AppConstants.healthDataUrl;
    User? currentUser = FirebaseAuth.instance.currentUser;
    print("Current user: ${currentUser?.email}");

    int backendUserId = await getBackendUserId(currentUser?.email);
    if (backendUserId == 0) {
      print("Invalid user ID. Cannot send data.");
      return; // Stop if there's no valid user ID
    }

    // Prepare data to send to the backend
    Map<String, dynamic> data = {
      'mood': mood.value,
      'symptoms': symptoms.value,
      'user': backendUserId,
      'created_at': DateTime.now().toIso8601String(),
    };

    print(
        "Prepared health data: ${json.encode(data)}"); // Log the data being sent

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Log the full response

      if (response.statusCode == 201) {
        // Check for successful creation
        print('Data sent successfully');
      } else {
        print('Failed to send data: ${response.body}');
      }
    } catch (error) {
      print('Error sending data: $error');
    }
  }

  void resetAssessment() {
    currentQuestionIndex.value = 0;
    selectedAnswers.clear();
    isAssessmentComplete(false);
    mood('');
    symptoms("Based on assessment responses"); // Reset default symptoms
    print("Assessment reset for a new attempt.");
  }
}
