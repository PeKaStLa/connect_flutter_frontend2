import 'package:pocketbase/pocketbase.dart';
import 'package:logger/logger.dart'; // Import the logger package

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
    return await pb.collection('areas').getFullList();
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
    _logger.i('Fetching initial messages for area_id: $areaId');
    return await pb.collection('chat_messages').getFullList(filter: 'area_id = "$areaId"');
  } catch (e) {
    _logger.e('Error fetching initalMessages from PocketBase: $e');
    // Rethrowing the error allows the caller to decide how to handle it.
    // You might want to implement more specific error handling based on your app's needs.
    rethrow;
  }
}
