import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/message_model.dart';

class ChatController extends GetxController {
  final int userId;
  final int therapistId;
  Timer? _refreshTimer;

  // Variables to manage messages and input state
  var messages = <Message>[].obs;
  var messageController = TextEditingController();
  var isFirstLoad = true.obs; // Track if it's the first load
  var isSendingMessage = false.obs; // Flag to check if a message is being sent
  var isLoadingMessages = false.obs; // Flag for loading state

  // Constructor to initialize the user and therapist IDs
  ChatController({required this.userId, required this.therapistId});

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
    _startPeriodicRefresh();
  }

  @override
  void onClose() {
    _stopPeriodicRefresh();
    super.onClose();
  }

  // Fetch messages from the API
  Future<void> fetchMessages() async {
    if (isLoadingMessages.value) {
      return; // Prevent fetching if already in progress
    }
    isLoadingMessages.value = true; // Set loading state

    try {
      final url = Uri.parse(
          '${AppConstants.chat}?user_id=${userId.toString()}&therapist_id=${therapistId.toString()}');
      // Print the URL and headers for debugging
      if (kDebugMode) {
        print("Fetching messages from: $url");
      }

      final response = await http.get(url);

      // Print response headers for debugging
      if (kDebugMode) {
        print("Response headers: ${response.headers}");
      }

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        var fetchedMessages =
            jsonData.map((msg) => Message.fromJson(msg, userId)).toList();
        fetchedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        messages.value = fetchedMessages; // Update the message list
        isFirstLoad.value = false; // Set to false after first load

        // Optionally log fetched messages
        if (kDebugMode) {
          print("Fetched messages:");
        }
        for (var message in fetchedMessages) {
          if (kDebugMode) {
            print(
                "${message.isSentByUser ? 'You' : 'Therapist'}: ${message.message}");
          }
        }
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching messages: $e');
      }
    } finally {
      isLoadingMessages.value = false; // Reset loading state after completion
    }
  }

  // Periodically refresh messages every 5 seconds
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchMessages();
    });
  }

  // Stop periodic refresh when not needed
  void _stopPeriodicRefresh() {
    _refreshTimer?.cancel();
  }

  // Add message locally to show in the UI instantly
  void addMessageLocally(String text) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: userId, // Pass the correct senderId
      receiverId: therapistId, // Pass the correct receiverId
      message: text,
      createdAt: DateTime.now(),
      isSentByUser: true,
      senderName: 'You', // Use the actual sender name if possible
      receiverName: 'Therapist', // Use the actual receiver name if possible
    );
    messages.add(message);
  }

  // Send message to the server
  Future<void> sendMessageToServer(String text) async {
    final message = Message(
      id: 0, // 0 is placeholder, actual ID will be generated from server
      senderId: userId, // Pass the correct senderId
      receiverId: therapistId, // Pass the correct receiverId
      message: text,
      createdAt: DateTime.now(),
      isSentByUser: true,
      senderName: 'You', // Replace with actual user name
      receiverName: 'Therapist', // Replace with actual therapist name
    );

    try {
      // Log the message to check the structure
      if (kDebugMode) {
        print('Sending message: ${message.toJson()}');
      }

      final response = await http.post(
        Uri.parse(AppConstants.chat),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message.toJson()),
      );

      // Print response status and body for debugging
      if (kDebugMode) {
        print("Response status: ${response.statusCode}");
      }
      if (kDebugMode) {
        print("Response body: ${response.body}");
      }

      // Print response headers for debugging
      if (kDebugMode) {
        print("Response headers: ${response.headers}");
      }

      if (response.statusCode != 201) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
    }
  }

  // Handle sending message
  void sendMessage() {
    // Prevent sending duplicate messages if a message is already being sent
    if (isSendingMessage.value) return;

    final messageText = messageController.text.trim();
    if (messageText.isNotEmpty) {
      isSendingMessage.value =
          true; // Set the flag to true when sending a message
      addMessageLocally(messageText);
      messageController.clear();

      // Send the message to the server after adding it locally
      Future.microtask(() => sendMessageToServer(messageText)).then((_) {
        isSendingMessage.value =
            false; // Reset the flag after the message is sent
      });
    }
  }
}
