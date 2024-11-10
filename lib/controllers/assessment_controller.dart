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
    {
      "question": "How do you feel about your work or studies?",
      "options": ["Motivated", "Okay", "Overwhelmed", "Disinterested"]
    },
    {
      "question": "Do you feel you have enough time for yourself?",
      "options": ["Always", "Sometimes", "Rarely", "Never"]
    },
    {
      "question": "Do you feel like your social relationships are fulfilling?",
      "options": [
        "Yes, very fulfilling",
        "Somewhat fulfilling",
        "Not fulfilling",
        "Not at all"
      ]
    },
  ];

  @override
  void onInit() {
    super.onInit();
    loadStoredData(); // Load stored score and badge on initialization
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadStoredData(); // Load stored data when user logs in
      } else {
        resetAssessment(); // Reset data when user logs out
      }
    });
  }

  // Save score and badge to shared preferences
  Future<void> saveScoreAndBadge() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        final userUid =
            currentUser.uid; // Use UID to avoid issues with email changes

        if (userUid.isEmpty) {
          print("No UID found for the user.");
          return;
        }

        // Save points and badge using UID as the key
        bool pointsSaved =
            await prefs.setInt('${userUid}_assessment_points', points.value);
        bool badgeSaved =
            await prefs.setString('${userUid}_assessment_badge', badge.value);

        if (pointsSaved && badgeSaved) {
          print(
              "Score and badge saved: points = ${points.value}, badge = ${badge.value}");
        } else {
          print("Failed to save score and badge.");
        }
      } else {
        print("No user is logged in. Can't save data.");
      }
    } catch (error) {
      print("Error saving score and badge: $error");
    }
  }

  // Load stored score and badge from shared preferences
  Future<void> loadStoredData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        final userUid = currentUser.uid; // Use UID to fetch saved data

        if (userUid.isEmpty) {
          print("No UID found for the user.");
          return;
        }

        // Load saved points and badge using UID as the key
        points.value = prefs.getInt('${userUid}_assessment_points') ?? 0;
        badge.value = prefs.getString('${userUid}_assessment_badge') ?? '';

        print(
            "Stored data loaded: points = ${points.value}, badge = ${badge.value}");
      } else {
        print("No user is logged in. Can't load data.");
      }
    } catch (error) {
      print("Error loading stored data: $error");
    }
  }

  // Evaluate the answer and update points
  void evaluateAnswer(String? answer) async {
    if (answer == null) {
      skippedQuestions.value++; // Increment skipped question count
      print("Question skipped. Total skipped: ${skippedQuestions.value}");
    } else {
      selectedAnswers[currentQuestionIndex.value] = answer;
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
    calculateResult(); // Calculate mood and update points based on mood
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
      // Calculate the mood based on answers, for example:
      switch (answer) {
        case "Good":
        case "Always":
        case "Motivated":
        case "Yes, very fulfilling":
          score += 10; // Positive answers contribute higher points
          break;
        case "Okay":
        case "Often":
        case "Somewhat fulfilling":
        case "Sometimes":
          score += 5; // Neutral answers contribute moderate points
          break;
        case "Stressed":
        case "Anxious":
        case "Overwhelmed":
        case "Not fulfilling":
        case "Rarely":
        case "Never":
          score += 2; // Negative answers contribute fewer points
          break;
      }
    });

    // Determine mood based on score range
    mood.value = score >= 50
        ? "Happy"
        : score >= 30
            ? "Anxious"
            : "Sad";

    // Adjust points based on the final mood
    points.value = (mood.value == "Happy") ? score + 20 : score;
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
