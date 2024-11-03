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
          // Display result when assessment is complete
          print("Displaying results to the user.");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.mood.value, // Use mood instead of result
                  style: Theme.of(context).textTheme.headlineSmall,
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
          // Display current question
          final question =
              controller.questions[controller.currentQuestionIndex.value];
          print(
              "Displaying question ${controller.currentQuestionIndex.value + 1}");
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                // Display answer options
                ...List<Widget>.from(
                  (question["options"] as List<String>)
                      .map((option) => RadioListTile<String>(
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
                          )),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}
