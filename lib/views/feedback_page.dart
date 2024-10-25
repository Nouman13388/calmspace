import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/feedback_controller.dart';

class FeedbackPage extends StatelessWidget {
  final FeedbackController controller = Get.put(FeedbackController());

  FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                controller.feedbackMessage.value = value;
              },
              decoration: const InputDecoration(
                labelText: 'Your Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value || controller.feedbackMessage.value.isEmpty
                  ? null
                  : () => controller.submitFeedback(),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Feedback'),
            )),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.feedbackList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (controller.feedbackList.isEmpty) {
                  return const Center(child: Text('No feedback available.'));
                }
                return ListView.builder(
                  itemCount: controller.feedbackList.length,
                  itemBuilder: (context, index) {
                    final feedback = controller.feedbackList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(feedback.message),
                        subtitle: Text(
                          'User ID: ${feedback.user}\n${feedback.createdAt.toIso8601String()}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
