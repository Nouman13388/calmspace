import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../controllers/dashboard_controller.dart';

class AssessmentController extends GetxController {
  var currentQuestionIndex = 0.obs;
  var selectedAnswers = <int, String>{}.obs;
  var isAssessmentComplete = false.obs;
  var mood = ''.obs; // Mood result
  var symptoms =
      "Based on assessment responses".obs; // Default symptoms message

  // Gamification properties
  var progress = 0.0.obs; // Progress tracker (0 to 1 scale)
  var points = 0.obs; // Total points earned
  var badge = ''.obs; // Badge awarded at the end
  var skippedQuestions = 0.obs; // Tracks number of skipped questions

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
    print("Initializing AssessmentController...");
    loadStoredData(); // Load stored score and badge on initialization
  }

  // Save score and badge to shared preferences
  Future<void> saveScoreAndBadge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('assessment_points', points.value);
    await prefs.setString('assessment_badge', badge.value);
    print(
        "Score and badge saved to shared preferences: points = ${points.value}, badge = ${badge.value}");
  }

  // Load score and badge from shared preferences
  Future<void> loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    points.value = prefs.getInt('assessment_points') ?? 0;
    badge.value = prefs.getString('assessment_badge') ?? '';
    print(
        "Loaded score: ${points.value}, badge: ${badge.value} from shared preferences.");
  }

  // Send health data to the backend
  Future<void> sendHealthData() async {
    final url = AppConstants.healthDataUrl;
    User? currentUser = FirebaseAuth.instance.currentUser;

    print("Sending health data for user: ${currentUser?.email}");
    int backendUserId = await getBackendUserId(currentUser?.email);
    if (backendUserId == 0) {
      print("Invalid user ID. Cannot send data.");
      return;
    }

    // Prepare data to send to backend
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
      }
    } catch (error) {
      print('Error sending data: $error');
    }
  }

  // Retrieve backend user ID from Firebase email
  Future<int> getBackendUserId(String? email) async {
    if (email == null || email.isEmpty) {
      print("Email parameter is required to fetch user ID.");
      return 0;
    }

    final url = '${AppConstants.userUrl}?email=$email';
    print("Fetching backend user ID for email: $email");

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("Fetched backend user ID: ${jsonResponse['id']}");
        return jsonResponse['id'];
      } else {
        print(
            'Failed to retrieve backend user ID: ${response.statusCode} - ${response.body}');
        return 0;
      }
    } catch (error) {
      print('Error fetching backend user ID: $error');
      return 0;
    }
  }

  // Skip the current question
  void skipQuestion() {
    skippedQuestions.value += 1;
    print("Skipped question. Total skipped: ${skippedQuestions.value}");

    if (currentQuestionIndex.value >= questions.length - 1) {
      print("All questions completed. Calculating result...");
      calculateResult();
      awardBadge();
      isAssessmentComplete(true);
      sendHealthData();
      saveScoreAndBadge();
    } else {
      currentQuestionIndex.value++;
      print("Moved to question index: ${currentQuestionIndex.value}");
      updateProgress();
    }
  }

  // Evaluate the selected answer, update progress and points
  void evaluateAnswer(String answer) {
    selectedAnswers[currentQuestionIndex.value] = answer;
    points.value += 10; // Award 10 points per answered question
    print("Evaluated answer: $answer. Total points: ${points.value}");
    updateProgress();

    if (currentQuestionIndex.value >= questions.length - 1) {
      print("All questions answered. Calculating result...");
      calculateResult();
      awardBadge();
      isAssessmentComplete(true);
      sendHealthData();
      saveScoreAndBadge();
    } else {
      currentQuestionIndex.value++;
      print("Moved to question index: ${currentQuestionIndex.value}");
    }
  }

  // Update the progress as a percentage of total questions
  void updateProgress() {
    progress.value = (currentQuestionIndex.value + 1) / questions.length;
    print("Progress updated: ${progress.value * 100}%");
  }

  // Calculate the result based on answers
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
        case "Yes, frequently":
          score += 1;
          break;
        case "No":
          score += 7;
          break;
      }
    }
    mood(score >= 30
        ? "Happy"
        : score >= 15
            ? "Anxious"
            : "Sad");
    print("Calculated mood: ${mood.value} based on score: $score");
    Get.find<DashboardController>()
        .updateHealthData(mood.value, symptoms.value);
  }

  // Award a badge based on total points and skipped questions
  void awardBadge() {
    if (points.value >= 50 && skippedQuestions.value == 0) {
      badge("Gold Star");
    } else if (points.value >= 30 && skippedQuestions.value <= 1) {
      badge("Silver Star");
    } else {
      badge("Bronze Star");
    }
    print("Awarded badge: ${badge.value}");
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
    print("Assessment reset.");
  }
}
