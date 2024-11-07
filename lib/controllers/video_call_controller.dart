import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../models/webrtc_model.dart';

class VideoCallController extends GetxController {
  final WebRTCModel _webRTCModel = WebRTCModel();

  var isCalling = false.obs;

  RTCVideoRenderer get localRenderer => _webRTCModel.localRenderer;
  RTCVideoRenderer get remoteRenderer => _webRTCModel.remoteRenderer;

  Future<void> startCall(String senderId, String receiverId) async {
    try {
      await _webRTCModel.startCall();
      isCalling.value = true;
    } catch (e) {
      print("Error starting call: $e");
    }
  }

  Future<void> endCall() async {
    try {
      await _webRTCModel.endCall();
      isCalling.value = false;
    } catch (e) {
      print("Error ending call: $e");
    }
  }

  @override
  Future<void> onClose() async {
    await _webRTCModel.disposeRenderers();
    super.onClose();
  }
}
