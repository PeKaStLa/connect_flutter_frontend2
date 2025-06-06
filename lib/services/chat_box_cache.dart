import 'dart:async';
import 'package:hive_ce/hive.dart';

class ChatBoxCache {
  static const String boxName = 'chat_box_cache';
  static const int maxCacheSize = 5;

  static Future<Box> _getBox() async {
    return await Hive.openBox(boxName);
  }

  static Future<void> addChatBoxToCache(String chatBoxId) async {
    final box = await _getBox();
    final cachedChatBoxes = box.get('cachedChatBoxes', defaultValue: []);

    if (cachedChatBoxes.contains(chatBoxId)) {
      cachedChatBoxes.remove(chatBoxId);
    }

    cachedChatBoxes.insert(0, chatBoxId);

    if (cachedChatBoxes.length > maxCacheSize) {
      cachedChatBoxes.removeLast();
    }

    box.put('cachedChatBoxes', cachedChatBoxes);
  }

  static Future<List<String>> getCachedChatBoxes() async {
    final box = await _getBox();
    return box.get('cachedChatBoxes', defaultValue: []);
  }

  static Future<dynamic> getChatBoxFromCache(String chatBoxId) async {
    final box = await _getBox();
    return box.get(chatBoxId);
  }

  static Future<void> saveChatBoxToCache(String chatBoxId, dynamic chatBoxData) async {
    final box = await _getBox();
    box.put(chatBoxId, chatBoxData);
  }
}