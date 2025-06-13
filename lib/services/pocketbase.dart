import 'package:pocketbase/pocketbase.dart';
import 'package:logger/logger.dart'; // Import the logger package
import 'package:connect_flutter/utils/pocketbase_constants.dart'; // Import constants

final pb = PocketBase('https://connect.pockethost.io');
final Logger _logger = Logger(); // Initialize the logger

/// Fetches all records from the 'areas' collection from PocketBase.
///
/// The records are sorted by 'someField' in descending order by default.
/// **Important:** You should replace `'someField'` with an actual field name
/// from your 'areas' collection in PocketBase. Alternatively, you could
/// modify this function to accept sort parameters if you need more flexibility.
///
/// Returns a `Future` that completes with a list of `RecordModel` objects,
/// each representing an area.
///
/// Throws a `ClientException` if the PocketBase request fails (e.g., network
/// issue, collection not found, invalid permissions), or other exceptions for
/// unexpected errors.
Future<List<RecordModel>> getAreas() async {
  try {
    // Fetches all records from the 'areas' collection.
    // The getFullList method is convenient for fetching all records at once.    
    return await pb.collection(PocketBaseCollections.areas).getFullList();
  } catch (e) {
    _logger.e('Error fetching areas from PocketBase: $e');
    // Rethrowing the error allows the caller to decide how to handle it.
    // You might want to implement more specific error handling based on your app's needs.
    rethrow;
  }
}

/// Fetches initial messages for a specific area_id from the 'chat_messages' collection.
///
/// [areaId] The ID of the area for which to fetch messages.
Future<List<RecordModel>> getInitialMessages(String areaId) async {
  try {
    // Fetches messages with the correct area_id records from the 'chat_messages' collection.
    // The getFullList method is convenient for fetching all records at once.    
    _logger.i('Fetching initial messages for ${PocketBaseChatFields.areaId}: $areaId');
    return await pb.collection(PocketBaseCollections.chatMessages)
        .getFullList(filter: '${PocketBaseChatFields.areaId} = "$areaId"');
  } catch (e) {
    _logger.e('Error fetching initalMessages from PocketBase: $e');
    // Rethrowing the error allows the caller to decide how to handle it.
    // You might want to implement more specific error handling based on your app's needs.
    rethrow;
  }
}

/// Sends a chat message to the 'chat_messages' collection in PocketBase.
///
/// [messageText] The content of the message.
/// [areaId] The ID of the area where the message is posted.
/// [userId] The ID of the user sending the message.
/// [messageId] The client-generated ID for the message.
///
/// Returns the created [RecordModel] on success.
/// Throws a `ClientException` if the PocketBase request fails.
Future<RecordModel> sendMessage({
  required String messageId,
  required String messageText,
  required String areaId,
  required String userId,
}) async {
  _logger.i('Sending message with ID: $messageId, Text: "$messageText" to area_id: $areaId by user_id: $userId');
  try {
    final body = <String, dynamic>{
      "id": messageId, // Add the client-generated ID
      PocketBaseChatFields.messageText: messageText,
      PocketBaseChatFields.areaId: areaId,
      PocketBaseChatFields.userId: userId,
    };
    return await pb.collection(PocketBaseCollections.chatMessages).create(body: body);
  } catch (e) {
    _logger.e('Error sending message to PocketBase: $e');
    // Rethrowing the error allows the caller to decide how to handle it.
    // You might want to implement more specific error handling based on your app's needs.
    rethrow;
  }
}
