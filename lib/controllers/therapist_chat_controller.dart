import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat_thread_model.dart';
import '../models/message_model.dart';

class TherapistChatController extends GetxController {
  var chatThreads = <ChatThread>[].obs; // Observable list of ChatThread
  late WebSocketChannel channel;

  void connect(String roomName) {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://127.0.0.1:8000/ws/chat/$roomName/'),
    );

    channel.stream.listen((data) {
      final parsedMessage = data.toString(); // Adjust parsing as needed
      String sender = 'User'; // Logic to determine sender
      var thread =
          chatThreads.firstWhere((thread) => thread?.roomName == roomName);

      thread.messages.add(Message(
        text: parsedMessage,
        sender: sender,
        timestamp: DateTime.now(),
      ));
    });
  }

  void sendMessage(String message, String roomName) {
    if (message.isNotEmpty) {
      channel.sink.add(message);
      var thread =
          chatThreads.firstWhere((thread) => thread.roomName == roomName);
      thread.messages.add(Message(
        text: message,
        sender: 'Therapist', // Therapist's name
        timestamp: DateTime.now(),
      ));
    }
  }

  @override
  void onClose() {
    channel.sink.close();
    super.onClose();
  }
}
