import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();
  late WebSocketChannel channel;
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  bool isReconnecting = false; // Flag to prevent infinite reconnect attempts

  void connect(String roomName) {
    print('Attempting to connect to room: $roomName');

    try {
      channel = WebSocketChannel.connect(
          Uri.parse('ws://50.19.24.133:8000/ws/chat/$roomName/'));
      print('WebSocket connection established to: $roomName');

      channel.stream.listen(
        (data) {
          print('Received data: $data');
          final decodedMessage = json.decode(data);
          if (decodedMessage['message'] != null) {
            messages
                .add({'message': decodedMessage['message'], 'isSent': false});
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

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      final message = messageController.text;
      print('Sending message: $message');
      channel.sink.add(json.encode({'message': message}));
      messages.add({'message': message, 'isSent': true});
      messageController.clear();
      print('Message sent successfully: $message');
    } else {
      print('Message text is empty; not sending.');
    }
  }

  void reconnect(String roomName) {
    print('Attempting to reconnect to room: $roomName');
    isReconnecting =
        true; // Set flag to true to prevent further reconnection attempts

    Future.delayed(Duration(seconds: 2), () {
      try {
        connect(roomName);
      } catch (e) {
        print('Reconnect attempt failed: $e');
      } finally {
        isReconnecting = false; // Reset the flag after trying to reconnect
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    // You might want to connect to a default room here
    // connect('defaultRoomName');
  }

  @override
  void onClose() {
    print('Closing WebSocket connection');
    channel.sink.close(status.goingAway);
    messageController.dispose();
    super.onClose();
  }
}
