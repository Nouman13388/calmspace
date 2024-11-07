import 'package:calmspace/views/video_call_pages/screens/create_room/create_room.dart';
import 'package:calmspace/views/video_call_pages/screens/join_room/join_room.dart';
import 'package:flutter/material.dart';

import 'constants/styles.dart';

class VideoCallPage extends StatelessWidget {
  const VideoCallPage({super.key});

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
              SizedBox(
                height: size.height * 0.06,
                width: size.width * 0.7,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CreateRoom())),
                  child: const Text('Create Room'),
                  style: RoundedButtonStyle,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: size.height * 0.06,
                width: size.width * 0.7,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const JoinRoom())),
                  child: const Text('Join Room'),
                  style: RoundedButtonStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
