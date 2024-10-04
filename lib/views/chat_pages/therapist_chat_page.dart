import 'package:flutter/material.dart';
import 'chat_page.dart'; // Import the ChatPage

class TherapistChatPage extends StatelessWidget {
  const TherapistChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatPage(userName: 'Therapist'); // Pass the user's name
  }
}
