// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/therapist_chat_controller.dart';
// import '../../controllers/user_chat_controller.dart';
// import '../../models/message_model.dart';
// import '../../models/chat_thread_model.dart';
//
// class ChatThreadView extends StatefulWidget {
//   final String roomName;
//   final String userName;
//
//   const ChatThreadView(
//       {super.key, required this.roomName, required this.userName});
//
//   @override
//   _ChatThreadViewState createState() => _ChatThreadViewState();
// }
//
// class _ChatThreadViewState extends State<ChatThreadView> {
//   late final TextEditingController _controller;
//   late final dynamic controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController();
//     controller = widget.userName == 'User'
//         ? Get.find<UserChatController>()
//         : Get.find<TherapistChatController>();
//
//     controller
//         .connect(widget.roomName); // Connect to the WebSocket for this thread
//     controller.loadChatThreads(); // Load dummy data
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with ${widget.userName}'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Obx(() {
//               final messages = controller.chatThreads
//                   .firstWhere((thread) => thread.roomName == widget.roomName)
//                   .messages;
//
//               return ListView.builder(
//                 itemCount: messages.length,
//                 itemBuilder: (context, index) {
//                   final message = messages[index];
//                   return _buildMessage(message);
//                 },
//               );
//             }),
//           ),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessage(Message message) {
//     final alignment =
//         message.sender == 'User' ? Alignment.centerRight : Alignment.centerLeft;
//     final color =
//         message.sender == 'User' ? Colors.blue[200] : Colors.grey[300];
//
//     return Align(
//       alignment: alignment,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 5),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(message.text, style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 4),
//             Text(
//               _formatDateTime(message.timestamp),
//               style: const TextStyle(fontSize: 10, color: Colors.black54),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMessageInput() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 hintText: 'Type a message...',
//                 border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(30)),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[200],
//               ),
//               onSubmitted: (value) {
//                 if (value.isNotEmpty) {
//                   controller.sendMessage(value, widget.roomName);
//                   _controller.clear();
//                 }
//               },
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.send),
//             onPressed: () {
//               if (_controller.text.isNotEmpty) {
//                 controller.sendMessage(_controller.text, widget.roomName);
//                 _controller.clear();
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatDateTime(DateTime dateTime) {
//     return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//   }
// }
