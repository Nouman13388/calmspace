import 'message_model.dart'; // Ensure this import exists

class ChatThread {
  final String userName;
  final String roomName;
  List<Message> messages;

  ChatThread({
    required this.userName,
    required this.roomName,
    List<Message>? messages,
  }) : messages = messages ?? [];
}
