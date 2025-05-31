import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:connect_flutter/models/area_data.dart'; // Import the Area model
import 'package:pocketbase/pocketbase.dart'; // Import PocketBase
import 'package:connect_flutter/controllers/hive_chat_controller.dart'; // Import HiveChatController
import 'package:logger/logger.dart'; // Import the logger package

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
  late HiveChatController _chatController;
  bool _isChatReady = false;
  String? _initializationError;
  final Logger _logger = Logger(); // Initialize the logger

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Sanitize the area name to make it a safe box name.
      // Replace spaces and special characters. Adjust regex as needed.
      final sanitizedAreaName = widget.area.name.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      
      _chatController = HiveChatController(chatId: sanitizedAreaName);
      await _chatController.init(); // CRITICAL: Call and await init() here

      if (mounted) {
        setState(() {
          // _chatController is already initialized and its _box is now set.
          _isChatReady = true;
        });
      }
    } catch (e, stackTrace) {
      _logger.e("Error initializing chat overlay for ${widget.area.name}", error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _initializationError = "Failed to load chat: $e";
          _isChatReady = false; // Explicitly set to false on error
        });
      }
    }
  }

  @override
  void dispose() {
    // Only dispose if the controller was successfully initialized
    if (_isChatReady) {
      // _chatController.dispose() is async.
      _chatController.dispose().catchError((e, s) {
        _logger.e("Error disposing chat controller for ${widget.area.name}", error: e, stackTrace: s);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 5,
      right: 60,
      child: Container(
        height: 400,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
          ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_isChatReady)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Chat in ${widget.area.name}\n(Box: ${_chatController.boxName})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (_initializationError != null)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Chat Error',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Loading Chat...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            Expanded(child: _buildChatContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent() {
    if (_initializationError != null) {
      return Center(child: Text(_initializationError!, style: const TextStyle(color: Colors.red)));
    }
    if (!_isChatReady) {
      return const Center(child: CircularProgressIndicator());
    }
    return Chat(
      chatController: _chatController,
      currentUserId: widget.pb.authStore.model?.id ?? 'guest_user', // Use PocketBase user or a default
      onMessageSend: (text) {
        _chatController.insertMessage(
          TextMessage(
            id: '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}', // More unique ID
            authorId: widget.pb.authStore.model?.id ?? 'guest_user',
            createdAt: DateTime.now().toUtc(),
            text: text,
          ),
        );
      },
      resolveUser: (UserID id) async {
        // Implement actual user resolution, e.g., from PocketBase
        if (id == widget.pb.authStore.model?.id) {
          return User(id: id, name: widget.pb.authStore.model?.data['name'] ?? 'You');
        }
        return User(id: id, name: 'User $id'); // Placeholder
      },
    );
  }
}