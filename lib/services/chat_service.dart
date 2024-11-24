import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl = 'http://16.171.9.75:8000/api/';

  Future<void> sendMessage(String message) async {
    final String url = '${baseUrl}messages/';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Message sent successfully: ${response.body}");
        }
      } else {
        if (kDebugMode) {
          print(
              "Failed to send message: ${response.statusCode} ${response.body}");
        }
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print("Network error: $e");
      }
    } catch (e) {
      if (kDebugMode) {
        print("An unexpected error occurred: $e");
      }
    }
  }
}
