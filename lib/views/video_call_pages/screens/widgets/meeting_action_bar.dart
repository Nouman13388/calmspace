import 'package:flutter/material.dart';

import '../../constants/styles.dart';
import 'meeting_action_button.dart';

class MeetingActionBar extends StatelessWidget {
  final bool isMicEnabled, isWebcamEnabled;
  final void Function() onCallEndButtonPressed,
      onMicButtonPressed,
      onWebcamButtonPressed;
  final double iconSize;

  const MeetingActionBar({
    super.key,
    required this.isMicEnabled,
    required this.isWebcamEnabled,
    required this.onCallEndButtonPressed,
    required this.onMicButtonPressed,
    required this.onWebcamButtonPressed,
    this.iconSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SizedBox(
        width: size.width * 0.85,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
                size, Colors.red, Icons.call_end, onCallEndButtonPressed),
            _buildActionButton(
              size,
              isMicEnabled ? hoverColor : secondaryColor.withOpacity(0.8),
              isMicEnabled ? Icons.mic : Icons.mic_off,
              onMicButtonPressed,
            ),
            _buildActionButton(
              size,
              isWebcamEnabled ? hoverColor : secondaryColor.withOpacity(0.8),
              isWebcamEnabled ? Icons.videocam : Icons.videocam_off,
              onWebcamButtonPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      Size size, Color backgroundColor, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: size.width * 0.2,
        child: MeetingActionButton(
          backgroundColor: backgroundColor,
          onPressed: onPressed,
          icon: icon,
          iconSize: iconSize,
        ),
      ),
    );
  }
}
