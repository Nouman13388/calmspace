import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/content_controller.dart';
import '../models/mental_health_content_model.dart'; // Import the model

class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ContentController contentController = Get.put(ContentController()); // Initialize the controller

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Resources'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Obx(() {
        if (contentController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (contentController.contentList.isEmpty) {
          return const Center(child: Text('No content available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: contentController.contentList.length,
          itemBuilder: (context, index) {
            final content = contentController.contentList[index];

            // Handle null safety for content fields
            final name = content.name ?? 'No Title';
            final description = content.description ?? 'No description available.';
            final lastReviewed = content.lastReviewed?.join(', ') ?? 'No review information available.';
            final relatedLinks = content.relatedLinks ?? [];
            final hasParts = content.hasParts ?? [];

            return Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last Reviewed: $lastReviewed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Show detailed information in a modal
                        _showDetails(context, content);
                      },
                      child: const Text('Read More'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: contentController.fetchContent,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  // Method to show detailed information in a modal
  void _showDetails(BuildContext context, MentalHealthContent content) {
    // Handle null safety for content fields
    final name = content.name ?? 'No Title';
    final description = content.description ?? 'No description available.';
    final lastReviewed = content.lastReviewed?.join(', ') ?? 'No review information available.';
    final relatedLinks = content.relatedLinks ?? [];
    final hasParts = content.hasParts ?? [];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 400, // Set height for the bottom sheet
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Last Reviewed:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(lastReviewed),
                const SizedBox(height: 16),
                const Text(
                  'Related Links:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...relatedLinks.map((link) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          // Handle link tapping (open in a browser or WebView)
                        },
                        child: Text(
                          link,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
                const Text(
                  'Details:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...hasParts.map((part) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        part.text!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
