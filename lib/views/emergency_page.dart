import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/emergency_controller.dart';

class EmergencySupportPage extends StatelessWidget {
  final EmergencySupportController controller =
      Get.put(EmergencySupportController());

  EmergencySupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Support"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: controller.helplines.length,
          itemBuilder: (context, index) {
            final helpline = controller.helplines[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      helpline["name"]!,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(helpline["description"] ?? "",
                        style: TextStyle(fontSize: 14)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.call, color: Colors.green),
                          onPressed: () =>
                              controller.callHelpline(helpline["phone"]!),
                        ),
                        IconButton(
                          icon: Icon(Icons.language, color: Colors.blue),
                          onPressed: () =>
                              controller.openWebsite(helpline["website"]!),
                        ),
                        if (helpline["whatsapp"] != null)
                          IconButton(
                            icon: Icon(Icons.chat, color: Colors.teal),
                            onPressed: () =>
                                controller.openWhatsApp(helpline["whatsapp"]!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
