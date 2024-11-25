import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feedback_controller.dart';

class FeedbackPage extends StatelessWidget {
  final FeedbackController feedbackController = Get.put(FeedbackController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We value your feedback!',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Soft peach color for the text box
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  feedbackController.feedbackMessage.value = value;
                },
                maxLines: 4,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your feedback here...',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            SizedBox(height: 20),
            Obx(() {
              return feedbackController.isLoading.value
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: feedbackController.submitFeedback,
                child: Text('Submit Feedback'),
              );
            }),
            SizedBox(height: 20),
            // Proper heading for the feedback list
            Text(
              'Previous Feedback',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (feedbackController.feedbackList.isEmpty) {
                  return Center(child: Text('No feedback available.'));
                }
                return ListView.builder(
                  itemCount: feedbackController.feedbackList.length,
                  itemBuilder: (context, index) {
                    final feedback = feedbackController.feedbackList[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          feedback.message,
                          style: Theme.of(context).textTheme.bodyLarge,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refresh the feedback data
          feedbackController.refreshFeedbackList(); // Call refresh method
        },
        backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
