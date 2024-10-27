import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

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
        print("Message sent successfully: ${response.body}");
      } else {
        print(
            "Failed to send message: ${response.statusCode} ${response.body}");
      }
    } on SocketException catch (e) {
      print("Network error: $e");
    } catch (e) {
      print("An unexpected error occurred: $e");
    }
  }
}
