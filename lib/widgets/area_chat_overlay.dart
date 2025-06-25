import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:connect_flutter/models/area_data.dart'; // Import the Area model
import 'package:pocketbase/pocketbase.dart'; // Import PocketBase
import 'package:connect_flutter/utils/hive_chat_controller.dart'; // Import HiveChatController
import 'package:connect_flutter/services/pocketbase.dart' as pocketbase_service; // Still needed for getInitialMessages
import 'package:connect_flutter/services/chat_middleware_local_backend.dart' as chat_middleware; // Import the new middleware
import 'package:connect_flutter/utils/pocketbase_constants.dart'; // Import constants
import 'package:logger/logger.dart'; // Import the logger package
import 'package:connect_flutter/services/chat_box_cache_class.dart'; // Import your service


class AreaChatOverlay extends StatefulWidget {
  final Area area;
  final PocketBase pb;
  final VoidCallback onClose;

  const AreaChatOverlay({
    super.key,
    required this.area,
    required this.pb,
    required this.onClose,
  });

  @override
  State<AreaChatOverlay> createState() => _AreaChatOverlayState();
}

class _AreaChatOverlayState extends State<AreaChatOverlay> {
  late HiveChatController _chatController;
  bool _isChatReady = false;
  String? _initializationError;
  final Logger _logger = Logger(); // Initialize the loggerrrrr

  @override
  void initState() {
    super.initState();
    _loadChatFromCacheOrInitialize();
  }

    String _generateBoxName(String areaName) {
    final sanitizedAreaName = areaName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return 'box_$sanitizedAreaName';
  }


  Future<void> _loadChatFromCacheOrInitialize() async {
    final boxName = _generateBoxName(widget.area.id);

    // Ensure the Hive box is open. ChatBoxCache().getBox() will return the opened
    // Box or throw an exception if it fails. It does not return null.
    final cachedBox = await  ChatBoxCache().getBox(boxName); // Variable 'cachedBox' is not strictly needed now.

    // The box is now open (either retrieved from cache or newly opened by ChatBoxCache).
    // Proceed to initialize the controller with data from this local Hive box.
    _logger.i("Chat box $boxName is open. Initializing controller from local Hive data.");
    _chatController = HiveChatController(chatId: boxName);
    await _chatController.init(); // Initialize the controller.

    if (mounted) {
      setState(() {
        _isChatReady = true;
      });
    }
    // The 'return;' was part of the original 'if' block.
    // The subsequent lines calling _initializeChat() are now effectively removed
    // from this execution path as they were the 'else' part of the always-true condition.
    if (cachedBox.isEmpty) {
      _initializeChat(); // Your API call
    }

  }


  Future<void> _initializeChat() async {
    try {
      // Sanitize the area name to make it a safe box name.
      // Replace spaces and special characters. Adjust regex as needed.
    final boxName = _generateBoxName(widget.area.id);

      _chatController = HiveChatController(chatId: boxName);
      await _chatController.init(); // CRITICAL: Call and await init() here
      _logger.i("HiveChatController initialized for box: ${_chatController.boxName}");

      // Fetch initial messages from PocketBase
      _logger.i("Fetching initial messages for area: ${widget.area.id}");
      final initialRecordMessages = await pocketbase_service.getInitialMessages(widget.area.id);
      _logger.i("Fetched ${initialRecordMessages.length} initial messages from backend for area ${widget.area.id}.");

      final List<Message> chatMessages = initialRecordMessages.map((record) {
        // --- IMPORTANT: Adjust these field names to match your 'chat_messages' collection in PocketBase ---
        final String textContent = record.data[PocketBaseChatFields.messageText] as String? ?? '';
        final String authorId = record.data[PocketBaseChatFields.userId] as String? ?? 'unknown_user';
        // --- End of fields to adjust ---

        final String messageId = record.id; // Use PocketBase record ID as message ID
        
        // PocketBase 'created' field is a UTC string. Parse it.
        // Fallback to current UTC time if parsing fails or 'created' is missing.
        final DateTime createdAt = DateTime.tryParse(record.data['created'])?.toLocal() ?? DateTime.now().toUtc();

        return TextMessage(
          id: messageId,
          authorId: authorId,
          createdAt: createdAt,
          text: textContent,
        );
      }).toList();

      // Set messages in the controller. This will replace any existing messages in Hive.
      await _chatController.setMessages(chatMessages);
      _logger.i("Set ${chatMessages.length} messages in HiveChatController for area ${widget.area.name}.");

      if (mounted) {
        setState(() {
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
    ChatBoxCache().closeAll();
  
  }
  

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 5,
      left: 5,
      right: 5,
      child: Container(
        height: 450,
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
                      'Chat in ${widget.area.name}\nID:${widget.area.id}\n(Box: ${_chatController.boxName})',
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
    final bool isLoggedIn = widget.pb.authStore.isValid;
    return Chat(
      chatController: _chatController,
      currentUserId: widget.pb.authStore.record?.id ?? 'guest_user', 
      onMessageSend: (String messageText) async {
        if (!isLoggedIn) {
          Fluttertoast.showToast(
          msg: "Only logged in users can send messages!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
          timeInSecForIosWeb: 4,
        );
          return;
        }
        await chat_middleware.processAndSendChatMessage(
          chatController: _chatController,
          areaId: widget.area.id,
          messageText: messageText,
          currentUserPb: widget.pb,
        );
      },
      resolveUser: (UserID id) async {
        // Implement actual user resolution, e.g., from PocketBase
        if (id == widget.pb.authStore.record?.id) {
          return User(id: id, name: widget.pb.authStore.record?.data['user_name'] ?? 'You');
        }
        return User(id: id, name: 'User $id'); // Placeholder
      },
    );
  }
}