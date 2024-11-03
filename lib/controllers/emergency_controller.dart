import 'package:flutter/material.dart';
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
    {
      "name": "Sneham Welfare Organisation Malaysia",
      "description": "Provides free, compassionate and confidential support.",
      "phone": "1800225757",
      "website": "https://www.facebook.com/snehammalaysia/",
      "whatsapp": "https://wa.me/60102945722",
    },
    {
      "name": "TALIAN HEAL 15555",
      "description":
          "Mental health crisis support offering tele-counseling services.",
      "phone": "15555",
      "website": "http://moh.gov.my/ncemh",
    },
    {
      "name": "Malaysian Mental Health Association (MMHA)",
      "description":
          "Dedicated to providing free and confidential support and information by phone.",
      "phone": "0327806803",
      "website": "https://mmha.org.my/",
    },
    {
      "name": "PT Foundation's Peer Listening Helpline",
      "description":
          "Creates a safe space for the LGBTQ+ community with peer support.",
      "phone": "0327876005",
      "website": "https://www.facebook.com/ptfmalaysia/",
    },
    {
      "name": "P.S. The Children Hotline",
      "description": "A hotline dedicated to supporting children.",
      "phone": "0167213065",
      "website": "https://www.psthechildren.org.my/",
    },
    {
      "name": "Talian Kasih 15999 Hotline",
      "description":
          "Support services including counseling for abuse and homelessness.",
      "phone": "15999",
      "website": "https://www.kpwkm.gov.my/",
      "whatsapp": "https://wa.me/600192615999",
    },
    {
      "name": "Buddy Bear Childline",
      "description":
          "A safe space for children and teenagers to share worries and concerns.",
      "phone": "1800182327",
      "website": "https://www.humankind.my/buddybear-helpline",
    },
    {
      "name": "Telenita Helpline",
      "description": "Legal information and counseling services for survivors.",
      "phone": "0162374221",
      "website": "https://www.awam.org.my/",
      "whatsapp": "https://wa.me/+600162374221",
    },
  ];

  // Open phone dialer with the given phone number
  Future<void> callHelpline(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        "Error",
        "Could not open the phone dialer.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
      );
    }
  }

  // Open website in the external browser
  Future<void> openWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        "Error",
        "Could not open the website.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
      );
    }
  }

  // Open WhatsApp link if available
  Future<void> openWhatsApp(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        "Error",
        "Could not open WhatsApp.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
      );
    }
  }
}
