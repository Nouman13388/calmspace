import 'dart:convert';

import 'package:flutter/material.dart';
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

  // Fetch messages from the API and sort them
  Future<void> fetchMessages() async {
    try {
      final url = Uri.parse(
          '${AppConstants.chat}?user_id=${userId.toString()}&therapist_id=${therapistId.toString()}');
      print('Request URL: $url'); // Log the URL for debugging

      final response = await http.get(url);
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        var fetchedMessages =
            jsonData.map((msg) => Message.fromJson(msg)).toList();
        fetchedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        messages.value = fetchedMessages; // Assign sorted messages
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  // Send a new message to the API
  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isNotEmpty) {
      try {
        final message = Message(
          id: 0, // API may generate the ID
          userId: userId,
          therapistId: therapistId,
          message: messageText,
          createdAt: DateTime.now(),
        );

        final response = await http.post(
          Uri.parse(AppConstants.chat),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(message.toJson()),
        );

        if (response.statusCode == 201) {
          await fetchMessages(); // Refresh the message list after sending a new one
          messageController.clear(); // Clear the input field
        } else {
          throw Exception('Failed to send message');
        }
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchMessages(); // Fetch initial messages when the controller is initialized
  }
}
