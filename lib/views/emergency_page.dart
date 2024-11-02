import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/emergency_controller.dart';

class EmergencySupportPage extends StatelessWidget {
  final EmergencySupportController controller =
      Get.put(EmergencySupportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency Support"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quickly access emergency helplines",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // List of helplines
            Expanded(
              child: ListView.builder(
                itemCount: controller.helplines.length,
                itemBuilder: (context, index) {
                  final helpline = controller.helplines[index];
                  return ListTile(
                    title: Text(helpline["name"]!),
                    subtitle: Text(helpline["phone"]!),
                    trailing: IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () =>
                          controller.callHelpline(helpline["phone"]!),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            SizedBox(height: 16),
            Text(
              "Connect with crisis support services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                controller.openCrisisSupportService(
                    "https://www.example-crisis-support.org");
              },
              child: Text("Open Crisis Support Website"),
            ),
            Divider(),
            SizedBox(height: 16),
            Text(
              "View emergency contact information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add a button to navigate to emergency contact page (implement as needed)
            ElevatedButton(
              onPressed: () {
                Get.toNamed(
                    '/emergencyContacts'); // Make sure to define this route
              },
              child: Text("View Emergency Contacts"),
            ),
          ],
        ),
      ),
    );
  }
}
