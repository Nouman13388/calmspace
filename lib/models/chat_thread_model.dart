import 'message_model.dart';

class ChatThread {
  final String roomName;
  final String userName; // Add this line
  final List<Message> messages;

  ChatThread({
    required this.roomName,
    required this.userName, // Initialize this in the constructor
    this.messages = const [],
  });
}
