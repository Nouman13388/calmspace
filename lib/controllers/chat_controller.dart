// chat_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatController extends GetxController {
  late WebSocketChannel channel;
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  void connect(String roomName) {
    print('Connecting to room: $roomName');

    // Initialize the WebSocket channel
    try {
      channel = WebSocketChannel.connect(Uri.parse('ws://16.171.9.75:8000/ws/chat/$roomName/'));
      print('WebSocket channel initialized: $channel');

      channel.stream.listen(
            (data) {
          print('Raw data received: $data');
          final decodedMessage = json.decode(data);
          print('Decoded message: $decodedMessage');

          if (decodedMessage['message'] != null) {
            messages.add({'message': decodedMessage['message'], 'isSent': false});
            print('Messages updated: ${messages.map((m) => m['message']).join(', ')}');
          } else {
            print('Received message has an invalid format: $decodedMessage');
          }
        },
        onError: (error) {
          printError(info: 'WebSocket error: ${error.toString()}');
          print('Error type: ${error.runtimeType}');
          print('Error stack trace: ${StackTrace.current}');
          // Attempt to reconnect
          reconnect(roomName);
        },
        onDone: () {
          print('WebSocket connection closed');
          // Attempt to reconnect
          reconnect(roomName);
        },
      );

      print('Successfully connected to the room: $roomName');
    } catch (e) {
      printError(info: 'Error connecting to the room: $e');
    }
  }

  void sendMessage(String message) {
    if (channel != null) {
      print('Sending message: $message');
      channel.sink.add(json.encode({'message': message}));
      messages.add({'message': message, 'isSent': true}); // Add sent message
      print('Message sent: $message');
    } else {
      print('Channel is not initialized. Cannot send message.');
    }
  }

  void reconnect(String roomName) {
    int attempt = 1;

    Future.delayed(const Duration(seconds: 2), () {
      while (attempt <= 5) {
        print('Attempting to reconnect (Attempt $attempt) to room: $roomName...');
        try {
          connect(roomName);  // Call connect without await
          break; // Exit if connection is successful
        } catch (e) {
          print('Reconnect attempt $attempt failed: $e');
        }
        attempt++;
        Future.delayed(Duration(seconds: attempt * 2)); // Exponential backoff
      }
      if (attempt > 5) {
        print('Max reconnect attempts reached. Giving up.');
      }
    });
  }

  @override
  void onClose() {
    print('Closing WebSocket connection');
    channel.sink.close();
    print('WebSocket connection closed successfully');
    super.onClose();
  }
}
