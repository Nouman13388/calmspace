import 'package:calmspace/views/video_call_pages/screens/create_room/create_room.dart';
import 'package:calmspace/views/video_call_pages/screens/join_room/join_room.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'constants/styles.dart';

class VideoCallPage extends StatelessWidget {
  const VideoCallPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(
                  size, 'Create Room', () => Get.to(() => CreateRoom())),
              const SizedBox(height: 20),
              _buildButton(size, 'Join Room', () => Get.to(() => JoinRoom())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(Size size, String text, VoidCallback onPressed) {
    return SizedBox(
      height: size.height * 0.06,
      width: size.width * 0.7,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
        style: RoundedButtonStyle,
      ),
    );
  }
}
