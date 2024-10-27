import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/assessment_question.dart';
import '../services/api_service.dart';

class AssessmentController extends GetxController {
  var questions = <AssessmentQuestion>[].obs;
  var isLoading = false.obs;

  final ApiService apiService = Get.put(ApiService());

  @override
  void onInit() {
    super.onInit();
    fetchAssessmentQuestions();
  }

  Future<void> fetchAssessmentQuestions() async {
    isLoading(true);
    try {
      final fetchedQuestions = await apiService.fetchAssessmentQuestions();
      if (fetchedQuestions.isNotEmpty) {
        questions.assignAll(fetchedQuestions);
        if (kDebugMode) {
          print('Fetched ${questions.length} questions from the backend');
        }
      } else {
        _showSnackbar("Notice", "No questions found.");
      }
    } catch (e) {
      _showSnackbar("Error", "Failed to load questions");
      if (kDebugMode) {
        print("Error fetching questions: $e");
      }
    } finally {
      isLoading(false);
    }
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}
