import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:get/get.dart'; // Assuming you're using GetX for state management

class ChatPage extends StatefulWidget {
  final String roomName;
  final String userId; // Pass the userId to the chat page
  final String professionalId; // Pass the professionalId to the chat page

  ChatPage({
    Key? key,
    required this.roomName,
    required this.userId,
    required this.professionalId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late WebSocketChannel _channel;
  final TextEditingController _messageController = TextEditingController();
  List<String> _messages = []; // List to hold messages

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    // Replace with your WebSocket server URL
    final String wsUrl = 'ws://your_websocket_server_url'; // Update this
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
        _messages.add(_messageController.text); // Add the message to the local list
        _messageController.clear(); // Clear the text field
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Professional'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          MessageInput(
            messageController: _messageController,
            sendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback sendMessage;

  MessageInput({
    Key? key,
    required this.messageController,
    required this.sendMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Send a message',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => sendMessage(), // Call sendMessage on submit
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: sendMessage, // Call sendMessage on button press
          ),
        ],
      ),
    );
  }
}
