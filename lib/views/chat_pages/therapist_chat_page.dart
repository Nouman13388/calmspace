import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/therapist_chat_controller.dart';
import 'chat_page.dart';

class TherapistChatPage extends StatelessWidget {
  final TherapistChatController therapistChatController =
      Get.put(TherapistChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist Chat Threads'),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: therapistChatController.chatThreads.length,
          itemBuilder: (context, index) {
            final thread = therapistChatController.chatThreads[index];
            return ListTile(
              title: Text(thread.userName),
              subtitle: Text(thread.messages.isNotEmpty
                  ? thread.messages.last.text
                  : 'No messages yet'),
              onTap: () {
                Get.to(() => ChatThreadView(
                    roomName: thread.roomName, userName: thread.userName));
              },
            );
          },
        );
      }),
    );
  }
}
