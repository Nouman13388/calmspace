import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/emergency_controller.dart';

class EmergencySupportPage extends StatelessWidget {
  final EmergencySupportController controller =
      Get.put(EmergencySupportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Support"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quickly access emergency helplines",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // List of helplines
            Expanded(
              child: ListView.builder(
                itemCount: controller.helplines.length,
                itemBuilder: (context, index) {
                  final helpline = controller.helplines[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(helpline["name"]!),
                      subtitle: Text(helpline["description"] ?? ""),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.call, color: Colors.green),
                            onPressed: () =>
                                controller.callHelpline(helpline["phone"]!),
                          ),
                          if (helpline["website"] != null)
                            IconButton(
                              icon: const Icon(Icons.language,
                                  color: Colors.blue),
                              onPressed: () =>
                                  controller.openWebsite(helpline["website"]!),
                            ),
                          if (helpline["whatsapp"] != null)
                            IconButton(
                              icon: const Icon(Icons.chat, color: Colors.teal),
                              onPressed: () => controller
                                  .openWhatsApp(helpline["whatsapp"]!),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Connect with crisis support services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                controller.openCrisisSupportService(
                  "https://breakthroughformen.org/?gad_source=1&gclid=Cj0KCQjwm5e5BhCWARIsANwm06jXIV7cEsC1JwodeYJ1X0kvo98HiEeZdlq_AUxTuZxbbI3Ica77C_oaAuUHEALw_wcB",
                );
              },
              child: const Text("Open Crisis Support Website"),
            ),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "View emergency contact information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(() => EmergencyContactsPage());
              },
              child: const Text("View Emergency Contacts"),
            ),
          ],
        ),
      ),
    );
  }
}

// Emergency Contacts Page
class EmergencyContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final emergencyContacts = [
      {
        "name": "Befrienders Kuala Lumpur",
        "phone": "0376272929",
        "website": "https://www.befrienders.org.my/"
      },
      {
        "name": "MIASA Crisis Helpline",
        "phone": "1800180066",
        "website": "https://miasa.org.my/",
        "whatsapp": "https://wa.me/60397656088"
      },
      {
        "name": "Sneham Welfare Organisation Malaysia",
        "phone": "1800225757",
        "website": "https://www.facebook.com/snehammalaysia/",
        "whatsapp": "https://wa.me/60102945722"
      },
      {
        "name": "TALIAN HEAL 15555",
        "phone": "15555",
        "website": "http://moh.gov.my/ncemh"
      },
      {
        "name": "Malaysian Mental Health Association (MMHA)",
        "phone": "0327806803",
        "website": "https://mmha.org.my/"
      },
      {
        "name": "PT Foundation's Peer Listening Helpline",
        "phone": "0327876005",
        "website": "https://www.facebook.com/ptfmalaysia/"
      },
      {
        "name": "P.S. The Children Hotline",
        "phone": "0167213065",
        "website": "https://www.psthechildren.org.my/"
      },
      {
        "name": "Talian Kasih 15999 Hotline",
        "phone": "15999",
        "website": "https://www.kpwkm.gov.my/",
        "whatsapp": "https://wa.me/600192615999"
      },
      {
        "name": "Buddy Bear Childline",
        "phone": "1800182327",
        "website": "https://www.humankind.my/buddybear-helpline"
      },
      {
        "name": "Telenita Helpline",
        "phone": "0162374221",
        "website": "https://www.awam.org.my/",
        "whatsapp": "https://wa.me/+600162374221"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Contacts"),
      ),
      body: ListView.builder(
        itemCount: emergencyContacts.length,
        itemBuilder: (context, index) {
          final contact = emergencyContacts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(contact["name"]!),
              subtitle: Text(contact["phone"]!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () {
                      FlutterPhoneDirectCaller.callNumber(contact["phone"]!);
                    },
                  ),
                  if (contact["website"] != null)
                    IconButton(
                      icon: const Icon(Icons.language, color: Colors.blue),
                      onPressed: () {
                        final uri = Uri.parse(contact["website"]!);
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                    ),
                  if (contact["whatsapp"] != null)
                    IconButton(
                      icon: const Icon(Icons.chat, color: Colors.teal),
                      onPressed: () {
                        final uri = Uri.parse(contact["whatsapp"]!);
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
