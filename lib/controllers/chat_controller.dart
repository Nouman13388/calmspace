import 'package:get/get.dart';
import 'package:calmspace/services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();

  Future<void> sendMessage(String message) async {
    try {
      await _chatService.sendMessage(message);
    } catch (e) {
      print("Failed to send message in controller: $e");
    }
  }
}
