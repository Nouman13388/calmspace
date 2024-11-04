import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          // Display result, points, and badge on assessment completion
          print("Displaying results to the user.");
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
          // Display current question, progress, and points
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
                  (question["options"] as List<String>).map(
                    (option) => RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: controller.selectedAnswers[
                          controller.currentQuestionIndex.value],
                      onChanged: (value) {
                        if (value != null) {
                          print("User selected answer: $value");
                          controller.evaluateAnswer(value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Skip Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      print(
                          "User skipped question ${controller.currentQuestionIndex.value + 1}");
                      controller
                          .skipQuestion(); // Calls skip function in the controller
                    },
                    child: const Text("Skip Question"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}
