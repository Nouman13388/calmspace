import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/assessment_controller.dart';

class AssessmentPage extends StatelessWidget {
  final AssessmentController controller = Get.put(AssessmentController());

  AssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Assessment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(), // Navigate back to the previous page
        ),
        backgroundColor: const Color(0xFFF3B8B5),
      ),
      backgroundColor: const Color(0xFFFFF8E1),
      body: Obx(() {
        // Show loading spinner while fetching data
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show a message if there are no questions to display
        if (controller.questions.isEmpty) {
          return const Center(child: Text("No questions available."));
        }

        // Display the questions if data is available
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.questions.length,
                    itemBuilder: (context, index) {
                      final question = controller.questions[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display the relevant information from the question
                              Text(
                                'Question ID: ${question.id}', // Display ID
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Type: ${question.type}', // Display type
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Result: ${question.result}', // Display result
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Created At: ${question.createdAt}', // Display creation date
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'User ID: ${question.user}', // Display user ID
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.fetchAssessmentQuestions,
        backgroundColor: const Color(0xFFF3B8B5),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Positioning the FAB
    );
  }
}
