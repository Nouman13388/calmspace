import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_chat_controller.dart';
import 'chat_page.dart';

class UserChatPage extends StatelessWidget {
  final UserChatController userChatController = Get.put(UserChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Chat Threads'),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: userChatController.chatThreads.length,
          itemBuilder: (context, index) {
            final thread = userChatController.chatThreads[index];
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
