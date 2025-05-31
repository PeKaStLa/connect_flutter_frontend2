import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:connect_flutter/models/area_data.dart'; // Import the Area model
import 'package:pocketbase/pocketbase.dart'; // Import PocketBase
import 'package:hive_ce/hive.dart';

class AreaChatOverlay extends StatefulWidget {
  final Area area;
  final PocketBase pb;
  final VoidCallback onClose;

  const AreaChatOverlay({
    super.key,
    required this.area,
    required this.onClose,
    required this.pb, // Require PocketBase instance
  });

  @override
  State<AreaChatOverlay> createState() => _AreaChatOverlayState();
}

class _AreaChatOverlayState extends State<AreaChatOverlay> {
  final _chatController = InMemoryChatController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 130,
      left: 0,
      right: 0,
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Chat in ${widget.area.name}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            Expanded(
              child: Chat(
                chatController: _chatController,
                currentUserId: 'user1',
                onMessageSend: (text) {
                  _chatController.insertMessage(
                    TextMessage(
                      id: '${Random().nextInt(1000) + 1}',
                      authorId: 'user1',
                      createdAt: DateTime.now().toUtc(),
                      text: text,
                    ),
                  );
                },
                resolveUser: (UserID id) async {
                  return User(id: id, name: 'John Doe');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}