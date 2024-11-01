import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_controller.dart';

class ChatPage extends StatelessWidget {
  final String roomName;
  final ChatController controller = Get.put(ChatController());

  ChatPage({Key? key, required this.roomName}) : super(key: key) {
    controller.connect(roomName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Room'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  bool isSent = message['isSent'] == true;
                  return Container(
                    alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(8.0),
                      elevation: 1.0,
                      color: isSent ? Colors.blue[200] : Colors.grey[300],
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(message['message'] ?? ''),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          MessageInput(controller: controller),
        ],
      ),
    );
  }
}

class MessageInput extends StatelessWidget {
  final ChatController controller;
  final TextEditingController _controller = TextEditingController();

  MessageInput({Key? key, required this.controller}) : super(key: key);

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      controller.sendMessage(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Send a message',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
