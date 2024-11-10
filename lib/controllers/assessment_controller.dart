import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../controllers/dashboard_controller.dart';

class AssessmentController extends GetxController {
  var currentQuestionIndex = 0.obs; // Index of the current question
  var selectedAnswers = <int, String>{}.obs; // Store selected answers
  var isAssessmentComplete =
      false.obs; // Flag to mark the completion of the assessment
  var mood = ''.obs; // Mood result
  var symptoms =
      "Based on assessment responses".obs; // Default value for symptoms

  // Gamification properties
  var progress = 0.0.obs; // Progress tracker (0 to 1 scale)
  var points = 0.obs; // Total points earned
  var badge = ''.obs; // Badge awarded at the end
  var skippedQuestions = 0.obs; // Tracks number of skipped questions

  var isLoading = false.obs; // Loading indicator

  // Example assessment questions
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
    {
      "question": "How often do you feel energetic throughout the day?",
      "options": ["Always", "Often", "Sometimes", "Rarely"]
    },
    {
      "question": "Do you have trouble sleeping?",
      "options": ["Yes, frequently", "Sometimes", "Rarely", "No"]
    },
  ];

  @override
  void onInit() {
    super.onInit();
    loadStoredData(); // Load stored score and badge on initialization
  }

  // Save score and badge to shared preferences
  Future<void> saveScoreAndBadge() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = currentUser.email ?? '';

      if (userEmail.isEmpty) {
        print("No email found for the user.");
        return;
      }

      final sanitizedEmail = _sanitizeEmail(userEmail);

      // Save points and badge using sanitized email keys
      await prefs.setInt('${sanitizedEmail}_assessment_points', points.value);
      await prefs.setString('${sanitizedEmail}_assessment_badge', badge.value);

      print(
          "Score and badge saved: points = ${points.value}, badge = ${badge.value}");
    } else {
      print("No user is logged in. Can't save data.");
    }
  }

  // Load score and badge from shared preferences
  Future<void> loadStoredData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = currentUser.email ?? '';

      if (userEmail.isEmpty) {
        print("No email found for the user.");
        return;
      }

      final sanitizedEmail = _sanitizeEmail(userEmail);

      // Load saved points and badge from shared preferences
      points.value = prefs.getInt('${sanitizedEmail}_assessment_points') ?? 0;
      badge.value = prefs.getString('${sanitizedEmail}_assessment_badge') ?? '';
      print("Loaded score: ${points.value}, badge: ${badge.value}");
    } else {
      print("No user is logged in. Can't load data.");
    }
  }

  // Helper function to sanitize email (remove any special characters)
  String _sanitizeEmail(String email) {
    return email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }

  // Evaluate the answer and update points
  void evaluateAnswer(String? answer) async {
    if (answer == null) {
      skippedQuestions.value++; // Increment skipped question count
      print("Question skipped. Total skipped: ${skippedQuestions.value}");
    } else {
      selectedAnswers[currentQuestionIndex.value] = answer;
      points.value += 10; // Award points per answered question
    }

    updateProgress(); // Update progress

    // Show loading indicator and delay before moving to next question
    isLoading.value = true;

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (currentQuestionIndex.value >= questions.length - 1) {
        completeAssessment();
      } else {
        currentQuestionIndex.value++; // Proceed to next question
      }
    } catch (error) {
      print('Error during evaluation: $error');
    } finally {
      isLoading.value = false;
    }
  }

  // Mark the assessment as complete
  void completeAssessment() {
    isAssessmentComplete(true);
    calculateResult();
    awardBadge();
    sendHealthData();
    saveScoreAndBadge(); // Store score and badge to SharedPreferences
    updateDashboard(); // Synchronize with DashboardController
  }

  // Update DashboardController with the new points and badge
  void updateDashboard() {
    final dashboardController = Get.find<DashboardController>();

    // Update points and badge in the DashboardController
    dashboardController.points.value = points.value;
    dashboardController.badge.value = badge.value;

    // Optionally, update the SharedPreferences in the DashboardController as well
    dashboardController.saveDashboardData();
  }

  // Update progress tracker based on the current question index
  void updateProgress() {
    progress.value = (currentQuestionIndex.value + 1) / questions.length;
  }

  // Calculate mood based on selected answers
  void calculateResult() {
    int score = 0;
    selectedAnswers.values.forEach((answer) {
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
        case "Yes, frequently":
          score += 1;
          break;
        case "No":
          score += 7;
          break;
      }
    });

    mood.value = score >= 30
        ? "Happy"
        : score >= 15
            ? "Anxious"
            : "Sad";
  }

  // Award a badge based on points
  void awardBadge() {
    if (points.value >= 50) {
      badge.value = "Gold Star";
    } else if (points.value >= 30) {
      badge.value = "Silver Star";
    } else {
      badge.value = "Bronze Star";
    }
  }

  // Reset assessment for a new attempt
  void resetAssessment() {
    currentQuestionIndex.value = 0;
    selectedAnswers.clear();
    isAssessmentComplete(false);
    mood('');
    symptoms("Based on assessment responses");
    progress.value = 0.0;
    points.value = 0;
    badge('');
    skippedQuestions.value = 0;
  }

  // Send health data to the backend
  Future<void> sendHealthData() async {
    final url = AppConstants.healthDataUrl;
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No user logged in. Can't send health data.");
      return;
    }

    int backendUserId = await getBackendUserId(currentUser.email);
    if (backendUserId == 0) {
      print("Invalid user ID. Cannot send data.");
      return;
    }

    // Prepare data for sending to backend
    Map<String, dynamic> data = {
      'mood': mood.value,
      'symptoms': symptoms.value,
      'user': backendUserId,
      'created_at': DateTime.now().toIso8601String(),
      'points': points.value,
      'badge': badge.value,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        print('Data sent successfully: ${response.body}');
      } else {
        print('Failed to send data: ${response.statusCode} - ${response.body}');
        Get.snackbar('Error', 'Failed to send health data to the server.');
      }
    } catch (error) {
      print('Error sending data: $error');
      Get.snackbar('Network Error', 'Could not send data. Please try again.');
    }
  }

  // Retrieve backend user ID from Firebase email
  Future<int> getBackendUserId(String? email) async {
    if (email == null || email.isEmpty) {
      print("Email parameter is required to fetch user ID.");
      return 0;
    }

    final url = '${AppConstants.userUrl}?email=$email';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['id'];
      } else {
        print('Failed to retrieve backend user ID: ${response.statusCode}');
        return 0;
      }
    } catch (error) {
      print('Error fetching backend user ID: $error');
      return 0;
    }
  }
}
