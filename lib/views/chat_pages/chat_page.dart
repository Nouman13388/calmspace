import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../controllers/chat_controller.dart';

class ChatPage extends StatelessWidget {
  final ChatController chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Page')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Chat message widgets
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Enter your message'),
                    onSubmitted: (message) async {
                      try {
                        await chatController.sendMessage(message);
                      } catch (e) {
                        printError(info: 'Error while sending message: $e');
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Trigger message send
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
