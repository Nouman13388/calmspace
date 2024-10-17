import '../models/chat_thread_model.dart';
import '../models/message_model.dart';

class MockChatService {
  static List<ChatThread> getDummyChatThreads() {
    return [
      ChatThread(
        roomName: 'chat_1',
        messages: [
          Message(
              text: 'Hello! How are you?',
              sender: 'Therapist',
              timestamp: DateTime.now().subtract(Duration(minutes: 10))),
          Message(
              text: 'I am fine, thank you!',
              sender: 'User',
              timestamp: DateTime.now().subtract(Duration(minutes: 5))),
          Message(
              text: 'What can I help you with today?',
              sender: 'Therapist',
              timestamp: DateTime.now()),
        ],
        userName: '',
      ),
      ChatThread(
        roomName: 'chat_2',
        messages: [
          Message(
              text: 'Hi! How have you been?',
              sender: 'Therapist',
              timestamp: DateTime.now().subtract(Duration(minutes: 15))),
          Message(
              text: 'I have been struggling a bit.',
              sender: 'User',
              timestamp: DateTime.now().subtract(Duration(minutes: 12))),
        ],
        userName: '',
      ),
    ];
  }
}
