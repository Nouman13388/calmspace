import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/content_controller.dart';
import '../../models/content.dart';

class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ContentController contentController = Get.put(ContentController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Resources'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (contentController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (contentController.contentList.isEmpty) {
          return const Center(child: Text('No content available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: contentController.contentList.length,
          itemBuilder: (context, index) {
            final content = contentController.contentList[index];
            final title = content.title ?? 'No Title';
            final description = content.description ?? 'No description available.';
            final date = content.date ?? 'No date available.';

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
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last Reviewed: $date',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
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
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _showDetails(BuildContext context, MentalHealthContent content) {
    final title = content.title ?? 'No Title';
    final description = content.description ?? 'No description available.';
    final date = content.date ?? 'No date available.';

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                Text(date),
              ],
            ),
          ),
        );
      },
    );
  }
}
