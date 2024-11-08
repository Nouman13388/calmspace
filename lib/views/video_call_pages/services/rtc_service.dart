import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../constants/configurations.dart';

class RTCService {
  late RTCPeerConnection peerConnection;
  final FirebaseFirestore videoapp = FirebaseFirestore.instance;

  RTCService() {
    init();
  }

  Future<void> init() async {
    peerConnection =
        await createPeerConnection(configuration, offerSdpConstraints);
  }

  Future<String> call() async {
    await init();
    final callDoc = videoapp.collection('calls').doc();
    final offerCandidates = callDoc.collection('offerCandidates');
    final answerCandidates = callDoc.collection('answerCandidates');

    peerConnection.onIceCandidate = (event) {
      if (event.candidate != null) {
        offerCandidates.add(event.toMap());
      }
    };

    callDoc.snapshots().listen((snapshot) async {
      final data = snapshot.data();
      if (data != null &&
          peerConnection.getRemoteDescription() == null &&
          data.containsKey('answer')) {
        peerConnection.setRemoteDescription(
          RTCSessionDescription(data['answer']['sdp'], data['answer']['type']),
        );
      }
    });

    answerCandidates.snapshots().listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          final candidate = RTCIceCandidate(
              data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
          peerConnection.addCandidate(candidate);
        }
      }
    });

    final offerDescription = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offerDescription);

    await callDoc.set({
      'offer': {'sdp': offerDescription.sdp, 'type': offerDescription.type}
    });
    return callDoc.id;
  }

  Future<void> answer(String roomID) async {
    await init();
    final callDoc = videoapp.collection('calls').doc(roomID);
    final answerCandidates = callDoc.collection('answerCandidates');
    final offerCandidates = callDoc.collection('offerCandidates');

    peerConnection.onIceCandidate = (event) {
      if (event.candidate != null) {
        answerCandidates.add(event.toMap());
      }
    };

    final callData = (await callDoc.get()).data();
    if (callData != null) {
      await peerConnection.setRemoteDescription(
        RTCSessionDescription(
            callData['offer']['sdp'], callData['offer']['type']),
      );

      final answerDescription = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answerDescription);
      await callDoc.update({
        'answer': {'sdp': answerDescription.sdp, 'type': answerDescription.type}
      });

      offerCandidates.snapshots().listen((snapshot) async {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data()!;
            final candidate = RTCIceCandidate(
                data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
            peerConnection.addCandidate(candidate);
          }
        }
      });
    }
  }
}
