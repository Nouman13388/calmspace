import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatController extends GetxController {
  late WebSocketChannel channel;
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  bool isReconnecting = false; // Flag to prevent infinite reconnect attempts

  void connect(String roomName) {
    print('Attempting to connect to room: $roomName');

    try {
      channel = WebSocketChannel.connect(Uri.parse('ws://50.19.24.133:8000/ws/chat/$roomName/'));
      print('WebSocket connection established to: $roomName');

      channel.stream.listen(
            (data) {
          print('Received data: $data');
          final decodedMessage = json.decode(data);
          if (decodedMessage['message'] != null) {
            messages.add({'message': decodedMessage['message'], 'isSent': false});
            print('Message received: ${decodedMessage['message']}');
          } else {
            print('Invalid message format: $decodedMessage');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          if (!isReconnecting) {
            reconnect(roomName);
          }
        },
        onDone: () {
          print('WebSocket connection closed');
          if (!isReconnecting) {
            reconnect(roomName);
          }
        },
      );
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }

  void sendMessage(String message) {
    if (channel != null) {
      print('Sending message: $message');
      channel.sink.add(json.encode({'message': message}));
      messages.add({'message': message, 'isSent': true});
      print('Message sent successfully: $message');
    } else {
      print('Channel is not initialized. Cannot send message.');
    }
  }

  void reconnect(String roomName) {
    print('Attempting to reconnect to room: $roomName');
    isReconnecting = true; // Set flag to true to prevent further reconnection attempts

    Future.delayed(Duration(seconds: 2), () {
      try {
        connect(roomName);
      } catch (e) {
        print('Reconnect attempt failed: $e');
        // Optionally, you could set isReconnecting to false here after a certain number of attempts
      } finally {
        isReconnecting = false; // Reset the flag after trying to reconnect
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
