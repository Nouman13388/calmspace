// pages/content_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/content_controller.dart'; // Import GetX

class ContentPage extends StatelessWidget {
  const ContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ContentController contentController = Get.put(ContentController()); // Initialize your controller

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Resources'),
      ),
      body: Obx(() { // Use Obx to listen for changes
        if (contentController.contentList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: contentController.contentList.length,
          itemBuilder: (context, index) {
            final content = contentController.contentList[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(content.title),
                subtitle: Text(content.description),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    contentController.deleteContent(content.id);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
