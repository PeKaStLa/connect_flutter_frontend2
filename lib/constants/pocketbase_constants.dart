// Contains constants related to PocketBase integration,
// such as collection names and field keys.

class PocketBaseCollections {
  static const String areas = 'areas';
  static const String chatMessages = 'chat_messages';
}

class PocketBaseAreaFields {
  // Already defined locally in area_data.dart, but could be centralized here
  // if used by services directly without going through the Area model.
}

class PocketBaseChatFields {
  static const String messageText = 'message_text';
  static const String areaId = 'area_id';
  static const String userId = 'user_id';
}