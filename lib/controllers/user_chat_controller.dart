// user_chat_controller.dart
import 'package:get/get.dart';
import '../models/chat_thread_model.dart';
import 'mock_chat_controller.dart';

class UserChatController extends GetxController {
  var chatThreads = <ChatThread>[].obs;

  void loadChatThreads() {
    chatThreads.addAll(MockChatService.getDummyChatThreads());
  }

  void connect(String roomName) {
    // Connect to WebSocket
  }

  void sendMessage(String messageText, String roomName) {
    // Handle sending the message
  }
}
