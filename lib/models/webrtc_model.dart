import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCModel {
  late MediaStream _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late RTCPeerConnection _peerConnection;

  WebRTCModel() {
    initRenderers();
  }

  // Initialize the local and remote renderers
  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  // Get the local media stream
  Future<MediaStream> getUserMedia() async {
    final mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'}
    };

    try {
      return await navigator.mediaDevices.getUserMedia(mediaConstraints);
    } catch (e) {
      print("Error getting user media: $e");
      throw Exception('Could not access camera and microphone');
    }
  }

  // Set up local stream and renderer
  Future<void> setupLocalStream() async {
    _localStream = await getUserMedia();
    _localRenderer.srcObject = _localStream;
  }

  // Create the peer connection
  Future<RTCPeerConnection> createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection();

    // Add local stream to the connection
    _peerConnection.addStream(_localStream);

    // Handle ICE candidate events
    _peerConnection.onIceCandidate = (candidate) {
      print("New ICE Candidate: ${candidate?.candidate}");
    };

    // Handle remote stream events
    _peerConnection.onAddStream = (stream) {
      _remoteRenderer.srcObject = stream;
    };

    return _peerConnection;
  }

  // Start the call
  Future<void> startCall() async {
    await setupLocalStream();
    await createPeerConnection();
  }

  // End the call
  Future<void> endCall() async {
    await _peerConnection.close();
    await _localStream.dispose();
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
  }

  // Dispose of renderers
  Future<void> disposeRenderers() async {
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
  }

  // Getters for accessing the renderers
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;
}
