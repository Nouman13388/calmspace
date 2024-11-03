import 'package:get/get.dart';

class AssessmentController extends GetxController {
  var currentQuestionIndex = 0.obs; // Track current question
  var selectedAnswers = <int, String>{}.obs; // Store answers by question index
  var isAssessmentComplete = false.obs; // Track if assessment is complete
  var result = ''.obs; // Store final result

  // Predefined questions
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
    // Add more questions as needed
  ];

  // Logic to determine the next question or result based on answers
  void evaluateAnswer(String answer) {
    // Store answer
    selectedAnswers[currentQuestionIndex.value] = answer;

    // Example logic to determine if assessment is complete
    if (currentQuestionIndex.value >= questions.length - 1) {
      calculateResult();
      isAssessmentComplete(true);
    } else {
      // Go to the next question
      currentQuestionIndex.value++;
    }
  }

  // Simple logic to calculate result based on answers
  void calculateResult() {
    int score = 0;

    // Example scoring: adjust based on real scoring criteria
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

    // Example result calculation based on total score
    if (score >= 20) {
      result("You seem to be doing well mentally!");
    } else if (score >= 10) {
      result("You may be experiencing some stress.");
    } else {
      result("Consider practicing mindfulness or seeking support.");
    }
  }

  // Reset assessment for a new attempt
  void resetAssessment() {
    currentQuestionIndex.value = 0;
    selectedAnswers.clear();
    isAssessmentComplete(false);
    result('');
  }
}
