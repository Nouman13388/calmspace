import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/chat_controller.dart';
import '../video_call_pages/video_call_screen.dart';

class ChatPage extends StatelessWidget {
  final ChatController chatController = Get.put(ChatController(
      userId: Get.arguments['userId'],
      therapistId: Get.arguments['therapistId']));
  final ScrollController _scrollController = ScrollController();

  ChatPage({super.key});

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    chatController.fetchMessages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Therapist'),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Video call button
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              chatController.userId.toString();
              chatController.therapistId.toString();

              Get.to(() => const VideoCallPage());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (chatController.isFirstLoad.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Sort messages by createdAt to show in chronological order
              chatController.messages
                  .sort((a, b) => a.createdAt.compareTo(b.createdAt));

              // Scroll to bottom after fetching messages
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              return ListView.builder(
                controller: _scrollController,
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  final isSentByUser =
                      message.senderId == chatController.userId;

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
                        constraints: const BoxConstraints(maxWidth: 250),
                        decoration: BoxDecoration(
                          color: isSentByUser
                              ? Colors.blueAccent
                              : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12.0),
                            topRight: const Radius.circular(12.0),
                            bottomLeft: isSentByUser
                                ? const Radius.circular(12.0)
                                : Radius.zero,
                            bottomRight: isSentByUser
                                ? Radius.zero
                                : const Radius.circular(12.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display sender and receiver names
                            Text(
                              '${message.senderName} to ${message.receiverName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            // Selectable text for messages
                            SelectableText(
                              message.message,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: isSentByUser
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('hh:mm a')
                                        .format(message.createdAt.toLocal()),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  if (isSentByUser) const SizedBox(width: 4.0),
                                  if (isSentByUser)
                                    const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.black54,
                                    ),
                                ],
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
          MessageInput(
            messageController: chatController.messageController,
            sendMessage: () {
              if (!chatController.isSendingMessage.value) {
                chatController.sendMessage();
                _scrollToBottom();
              }
            },
          ),
        ],
      ),
    );
  }
}

class MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback sendMessage;

  const MessageInput({
    super.key,
    required this.messageController,
    required this.sendMessage,
  });

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
                labelStyle: const TextStyle(color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.blue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide:
                      const BorderSide(color: Colors.blueAccent, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide:
                      const BorderSide(color: Colors.blueAccent, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide:
                      const BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}
