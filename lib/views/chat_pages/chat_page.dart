// chat_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_controller.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController chatController = Get.put(ChatController());
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Get the room name from the user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getRoomName();
    });
  }

  void _getRoomName() async {
    String? roomName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String tempRoomName = '';
        return AlertDialog(
          title: Text('Enter Room Name'),
          content: TextField(
            onChanged: (value) {
              tempRoomName = value;
            },
            decoration: InputDecoration(hintText: 'Room name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(tempRoomName);
              },
              child: Text('Join'),
            ),
          ],
        );
      },
    );

    // Connect to the chat room
    if (roomName != null && roomName.isNotEmpty) {
      chatController.connect(roomName);
    } else {
      chatController.connect('default_room'); // Connect with a default room name
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Room')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: chatController.messages[index]['isSent']
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: chatController.messages[index]['isSent']
                            ? Colors.blue[200]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(chatController.messages[index]['message']),
                    ),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: 'Enter your message'),
                    onSubmitted: (message) {
                      _sendMessage();
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      chatController.sendMessage(message);
      messageController.clear();
    }
  }

  @override
  void dispose() {
    chatController.onClose();
    messageController.dispose();
    super.dispose();
  }
}