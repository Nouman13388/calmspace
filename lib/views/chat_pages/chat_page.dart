import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/chat_controller.dart';

class ChatPage extends StatelessWidget {
  final ChatController chatController = Get.put(ChatController(
      userId: Get.arguments['userId'],
      therapistId: Get.arguments['therapistId']));
  final ScrollController _scrollController = ScrollController();

  // This method scrolls to the bottom of the list when a new message is added or after sending a message.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Therapist'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              // If no messages, show a loading indicator
              if (chatController.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Sorting messages to make sure they are ordered correctly
              chatController.messages
                  .sort((a, b) => a.createdAt.compareTo(b.createdAt));

              // Scroll to the bottom when the messages are updated
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              return ListView.builder(
                controller: _scrollController,
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  final isSentByUser = message.userId == chatController.userId;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 5.0,
                    ),
                    child: Align(
                      alignment: isSentByUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        constraints: BoxConstraints(maxWidth: 250),
                        decoration: BoxDecoration(
                          color: isSentByUser
                              ? Colors.blue[100]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                            bottomLeft: isSentByUser
                                ? Radius.circular(12.0)
                                : Radius.zero,
                            bottomRight: isSentByUser
                                ? Radius.zero
                                : Radius.circular(12.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.message,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: isSentByUser
                                    ? Colors.black
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                // Format the timestamp
                                DateFormat('hh:mm a')
                                    .format(message.createdAt.toLocal()),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          // Message input widget
          MessageInput(
            messageController: chatController.messageController,
            sendMessage: () {
              // Send message and scroll to the bottom
              chatController.sendMessage();
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }
}

// Message input widget for typing and sending messages
class MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback sendMessage;

  const MessageInput({
    Key? key,
    required this.messageController,
    required this.sendMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Type your message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onSubmitted: (_) => sendMessage(), // Send message on submitting
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: sendMessage, // Send message on button press
          ),
        ],
      ),
    );
  }
}
