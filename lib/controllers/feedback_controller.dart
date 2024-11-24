import 'package:calmspace/services/api_service.dart'; // Ensure this import is correct
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/feedback_model.dart';
import 'user_controller.dart'; // Import the UserController

class FeedbackController extends GetxController {
  var feedbackMessage = ''.obs;
  var isLoading = false.obs;
  var feedbackList = <Feedback>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllFeedback(); // Fetch all feedback when the controller is initialized
  }

  Future<void> fetchAllFeedback() async {
    isLoading.value = true;
    try {
      // Call ApiService to get all feedback
      final feedbackData = await ApiService().getAllFeedback();
      if (feedbackData != null) {
        feedbackList.value = feedbackData;
        if (kDebugMode) {
          print(feedbackData);
        }
      } else {
        if (kDebugMode) {
          print('Failed to load feedback');
        }
        Get.snackbar('Error', 'Failed to load feedback');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Something went wrong: $e');
      }
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitFeedback() async {
    if (feedbackMessage.value.isEmpty) {
      if (kDebugMode) {
        print('Feedback message cannot be empty');
      }
      Get.snackbar('Error', 'Feedback message cannot be empty');
      return;
    }

    // Fetch the logged-in user's ID dynamically using UserController
    final userId =
        await Get.find<UserController>().getLoggedInUserId(); // Get the user ID

    if (userId == null) {
      if (kDebugMode) {
        print('No logged-in user found');
      }
      Get.snackbar('Error', 'No logged-in user found');
      return;
    }

    isLoading.value = true;

    Feedback feedback = Feedback(
      message: feedbackMessage.value,
      createdAt: DateTime.now(),
      user: userId, // Use the dynamically fetched user ID
    );

    try {
      // Call ApiService to submit feedback
      final success = await ApiService().submitFeedback(feedback);
      if (success) {
        if (kDebugMode) {
          print('Feedback submitted successfully');
        }
        Get.snackbar('Success', 'Feedback submitted successfully!');
        feedbackMessage.value = '';
        fetchAllFeedback(); // Refresh the list to include the new feedback
      } else {
        if (kDebugMode) {
          print('Failed to submit feedback');
        }
        Get.snackbar('Error', 'Failed to submit feedback');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Something went wrong: $e');
      }
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshFeedbackList() {
    fetchAllFeedback(); // Call the method to refresh the feedback list
  }
}
