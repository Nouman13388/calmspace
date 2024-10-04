import 'package:flutter/material.dart';
import 'chat_page.dart'; // Import the ChatPage

class UserChatPage extends StatelessWidget {
  const UserChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatPage(userName: 'User'); // Pass the therapist's name
  }
}
