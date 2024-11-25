import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/assessment_controller.dart';

class AssessmentPage extends StatelessWidget {
  final AssessmentController controller = Get.put(AssessmentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Assessment'),
        backgroundColor: const Color(0xFFF3B8B5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            print("Navigating back from assessment page.");
            Get.back();
          },
        ),
      ),
      backgroundColor: const Color(0xFFFFF8E1),
      body: Obx(() {
        if (controller.isAssessmentComplete.value) {
          print("Displaying results to the user.");
          _saveAssessmentResult(controller.mood.value, controller.points.value,
              controller.badge.value);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Your Mood: ${controller.mood.value}",
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "You earned ${controller.points.value} points!",
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                if (controller.badge.value.isNotEmpty)
                  Text(
                    "Congratulations! You earned a ${controller.badge.value} badge!",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    print("Retaking assessment...");
                    controller.resetAssessment();
                  },
                  child: const Text("Retake Assessment"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3B8B5),
                  ),
                ),
              ],
            ),
          );
        } else {
          final question =
              controller.questions[controller.currentQuestionIndex.value];
          print(
              "Displaying question ${controller.currentQuestionIndex.value + 1}");

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Points and progress bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Points: ${controller.points.value}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Question ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: controller.progress.value,
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                  minHeight: 8,
                ),
                const SizedBox(height: 16),
                // Question and options
                Text(
                  "Question ${controller.currentQuestionIndex.value + 1}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  question["question"] as String,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ...List<Widget>.from(
                  (question["options"] as List<String>)
                      .map((option) => Obx(() => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: controller.selectedAnswers[controller
                                          .currentQuestionIndex.value] ==
                                      option
                                  ? Colors.lightGreenAccent.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: RadioListTile<String>(
                              title: Text(option),
                              value: option,
                              groupValue: controller.selectedAnswers[
                                  controller.currentQuestionIndex.value],
                              onChanged: (value) async {
                                if (value != null) {
                                  print("User selected answer: $value");
                                  controller.evaluateAnswer(value);

                                  // Show loading and delay before moving to next question
                                  controller.isLoading.value =
                                      true; // Show loading indicator

                                  // Add delay for processing
                                  await Future.delayed(
                                      const Duration(seconds: 1));
                                }
                              },
                            ),
                          ))),
                ),
                if (controller.isLoading.value)
                  const Center(
                    child:
                        CircularProgressIndicator(), // Display loading spinner
                  ),
              ],
            ),
          );
        }
      }),
    );
  }

  // Function to save the assessment result in shared preferences
  Future<void> _saveAssessmentResult(
      String mood, int points, String badge) async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser; // Get logged-in user
    final uid = user?.uid ?? 'guest'; // Use 'guest' if no user is logged in

    final data = {
      'mood': mood,
      'points': points,
      'badge': badge,
    };

    await prefs.setString(uid, json.encode(data));
    print("Assessment result saved for UID $uid: $data");
  }

  // Function to load the assessment result from shared preferences
  Future<void> _loadAssessmentResult() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'guest';

    final result = prefs.getString(uid);
    if (result != null) {
      final data = json.decode(result);
      print("Loaded assessment result for UID $uid: $data");
    }
  }
}
