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
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: const Color(0xFFFFF8E1),
      body: Obx(() {
        if (controller.isAssessmentComplete.value) {
          // Display result when assessment is complete
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.result.value,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.resetAssessment,
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
