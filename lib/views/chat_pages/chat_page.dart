import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

<<<<<<< Updated upstream
class ChatPage extends StatelessWidget {
  final String roomName;
  final ChatController controller = Get.put(ChatController());

  ChatPage({Key? key, required this.roomName}) : super(key: key) {
    controller.connect(roomName);
=======
class ChatPage extends StatefulWidget {
  final String userId; // Pass the userId to the chat page
  final String professionalId; // Pass the professionalId to the chat page

  ChatPage({required this.userId, required this.professionalId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late WebSocketChannel _channel;
  final TextEditingController _messageController = TextEditingController();
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    // Replace with your WebSocket server URL
    final String wsUrl = 'ws://your_websocket_server_url';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel.stream.listen((data) {
      setState(() {
        _messages.add(data.toString());
      });
    }, onError: (error) {
      // Handle error here
      print('WebSocket error: $error');
    }, onDone: () {
      // Handle when the WebSocket closes
      print('WebSocket closed');
    });
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _channel.sink.add(_messageController.text);
      setState(() {
        _messages.add(_messageController.text);
        _messageController.clear();
      });
    }
>>>>>>> Stashed changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< Updated upstream
        title: const Text('Chat Room'),
=======
        title: Text('Chat with Professional'),
>>>>>>> Stashed changes
      ),
      body: Column(
        children: [
          Expanded(
<<<<<<< Updated upstream
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
=======
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Send a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
>>>>>>> Stashed changes
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
