import 'package:pocketbase/pocketbase.dart'; // For PocketBase type
import 'package:logger/logger.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:connect_flutter/utils/hive_chat_controller.dart';
import 'package:connect_flutter/utils/chat_utils.dart' as chat_utils;
import 'package:connect_flutter/services/pocketbase.dart' as pocketbase_service; // To call the actual sendMessage

final Logger _logger = Logger();

/// Handles the creation of a chat message, inserts it into the local controller,
/// and sends it to the PocketBase backend.
///
/// [chatController] The local HiveChatController to insert the message into.
/// [areaId] The ID of the area for which the message is intended.
/// [messageText] The raw text content of the message.
/// [currentUserPb] The PocketBase instance, used to get the current authenticated user.
Future<void> processAndSendChatMessage({
  required HiveChatController chatController,
  required String areaId,
  required String messageText,
  required PocketBase currentUserPb,
}) async {
  final authorId = currentUserPb.authStore.record?.id ?? 'guest_user';
  final String newMessageId = chat_utils.generateMessageId(15);

  final textMessage = TextMessage(
    id: newMessageId,
    authorId: authorId,
    createdAt: DateTime.now().toUtc(),
    text: messageText,
  );

  // 1. Insert locally first for immediate UI update
  await chatController.insertMessage(textMessage);

  // 2. Then, send to backend
  try {
    _logger.i("Attempting to send message to backend for area $areaId with ID: $newMessageId");
    await pocketbase_service.sendMessage( // Calling the sendMessage function from pocketbase_service.dart
      messageId: newMessageId,
      messageText: textMessage.text,
      areaId: areaId,
      userId: authorId,
    );
    _logger.i("Message sent to backend successfully for area $areaId with ID: $newMessageId");
  } catch (e) {
    _logger.e("Failed to send message to backend for area $areaId with ID $newMessageId: $e");
    // Optional: Implement retry logic or update message status to 'failed to send' in UI
  }
}