import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencySupportController extends GetxController {
  final helplines = [
    {
      "name": "Befrienders Kuala Lumpur",
      "description":
          "Offers free and confidential emotional support for anyone feeling distressed.",
      "phone": "0376272929",
      "website": "https://www.befrienders.org.my/",
    },
    {
      "name": "MIASA Crisis Helpline",
      "description":
          "Provides 24/7, free and confidential support by phone for everyone in Malaysia.",
      "phone": "1800180066",
      "website": "https://miasa.org.my/",
      "whatsapp": "https://wa.me/60397656088",
    },
    // Add other helplines here...
  ];

  Future<void> callHelpline(String phone) async {
    await FlutterPhoneDirectCaller.callNumber(phone);
  }

  Future<void> openWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openWhatsApp(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Define openCrisisSupportService method
  Future<void> openCrisisSupportService(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not open the crisis support service URL.");
    }
  }
}
