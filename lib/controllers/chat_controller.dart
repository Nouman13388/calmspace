import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../models/message_model.dart';
import '../models/chat_thread_model.dart';
import '../services/web_socket_service.dart';

class ChatController extends GetxController {
  RxList<ChatThread> chatThreads = <ChatThread>[].obs;

  void connect(String roomName) {
    // TODO: Implement WebSocket connection here
  }

  void sendMessage(String messageText, String roomName) {
    final message = Message(
      text: messageText,
      sender: 'User', // Change based on the actual sender
      timestamp: DateTime.now(),
    );

    // Find the chat thread and add the message
    var thread = chatThreads.firstWhere((thread) => thread.roomName == roomName);
    thread.messages.add(message);
    chatThreads.refresh();

    // TODO: Send message over WebSocket
  }

  void loadChatThreads() {
    // Load initial chat threads (can be from an API or local)
    chatThreads.value = [
      ChatThread(roomName: 'Room1', messages: [], userName: ''),
      ChatThread(roomName: 'Room2', messages: [], userName: ''),
    ];
  }
}

class TherapistChatController extends GetxController {
  final WebSocketService webSocketService = WebSocketService();
  var chatThreads = <ChatThread>[].obs;

  void connect(String roomName) {
    webSocketService.connect(roomName);
    // Optionally, load existing chat threads from a backend or local storage.
  }

  void sendMessage(String messageText, String roomName) {
    webSocketService.sendMessage(messageText, roomName);
  }

  @override
  void onInit() {
    super.onInit();
    // Load existing chat threads if necessary.
  }
}

class UserChatController extends GetxController {
final WebSocketService webSocketService = WebSocketService();
var chatThreads = <ChatThread>[].obs;

void connect(String roomName) {
  webSocketService.connect(roomName);
  // Optionally, load existing chat threads from a backend or local storage.
}

void sendMessage(String messageText, String roomName) {
  webSocketService.sendMessage(messageText, roomName);
}

@override
void onInit() {
  super.onInit();
  // Load existing chat threads if necessary.
}
}
