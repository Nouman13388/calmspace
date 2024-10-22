// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import '../constants/app_constants.dart';
// import '../models/message_model.dart';
// import '../models/chat_thread_model.dart';
//
// class WebSocketService {
//   late final WebSocketChannel channel;
//   final List<ChatThread> chatThreads = [];
//
//   void connect(String roomName) {
//     channel = WebSocketChannel.connect(
//       Uri.parse('${AppConstants.websocketUrl}$roomName'),
//     );
//
//     channel.stream.listen(
//           (data) {
//         _handleMessage(data);
//       },
//       onError: (error) {
//         // Handle error
//         print('WebSocket error: $error');
//       },
//       onDone: () {
//         // Handle connection closed
//         print('WebSocket closed');
//       },
//     );
//   }
//
//   void sendMessage(String messageText, String roomName) {
//     final message = {
//       'sender': 'User', // Adjust as necessary
//       'text': messageText,
//       'timestamp': DateTime.now().toIso8601String(),
//       'roomName': roomName,
//     };
//     channel.sink.add(json.encode(message));
//   }
//
//   void _handleMessage(String data) {
//     final Map<String, dynamic> jsonData = json.decode(data);
//     final message = Message(
//       sender: jsonData['sender'],
//       text: jsonData['text'],
//       timestamp: DateTime.parse(jsonData['timestamp']),
//     );
//
//     final roomName = jsonData['roomName'];
//
//     // Find or create the chat thread
//     final chatThread = chatThreads.firstWhere(
//           (thread) => thread.roomName == roomName,
//       orElse: () {
//         // Create a new chat thread if it doesn't exist
//         final newThread = ChatThread(roomName: roomName, messages: [], userName: jsonData['userName'] ?? '');
//         chatThreads.add(newThread);
//         return newThread;
//       },
//     );
//
//     chatThread.messages.add(message);
//   }
//
//   void disconnect() {
//     channel.sink.close();
//   }
// }
