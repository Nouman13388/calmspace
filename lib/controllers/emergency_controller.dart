import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencySupportController extends GetxController {
  // List of helplines (for demonstration)
  final helplines = [
    {"name": "National Helpline", "phone": "+18001234567"},
    {"name": "Crisis Support", "phone": "+18007654321"},
  ];

  // Open dialer with the given phone number
  void callHelpline(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Error", "Cannot launch phone dialer");
    }
  }

  // Open URL for external crisis support services
  void openCrisisSupportService(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Cannot open URL");
    }
  }
}
