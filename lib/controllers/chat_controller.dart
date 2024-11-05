import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/message_model.dart';

class ChatController extends GetxController {
  final int userId;
  final int therapistId;

  ChatController({required this.userId, required this.therapistId});

  var messages = <Message>[].obs;
  var messageController = TextEditingController();

  Future<void> fetchMessages() async {
    try {
      final url = Uri.parse(
          '${AppConstants.chat}?user_id=${userId.toString()}&therapist_id=${therapistId.toString()}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        var fetchedMessages =
            jsonData.map((msg) => Message.fromJson(msg)).toList();
        fetchedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        messages.value = fetchedMessages;
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  void addMessageLocally(String text) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: userId,
      therapistId: therapistId,
      message: text,
      createdAt: DateTime.now(),
    );
    messages.add(message);
  }

  Future<void> sendMessageToServer(String text) async {
    final message = Message(
      id: 0,
      userId: userId,
      therapistId: therapistId,
      message: text,
      createdAt: DateTime.now(),
    );

    try {
      final response = await http.post(
        Uri.parse(AppConstants.chat),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void sendMessage() {
    final messageText = messageController.text.trim();
    if (messageText.isNotEmpty) {
      addMessageLocally(messageText);
      messageController.clear();

      Future.microtask(() => sendMessageToServer(messageText));
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
  }
}
