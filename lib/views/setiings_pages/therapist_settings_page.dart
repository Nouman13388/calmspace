import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TherapistSettingsPage extends StatelessWidget {
  const TherapistSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAllNamed('/therapist-homepage'); // Navigate back using GetX
          },
        ),
      ),
      body: Center(
        child: Text(
          'This is the Settings Page',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}
