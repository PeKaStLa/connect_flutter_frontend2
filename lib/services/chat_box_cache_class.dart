import 'dart:async';
//import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class ChatBoxCache {
  static final ChatBoxCache _instance = ChatBoxCache._internal();
  factory ChatBoxCache() => _instance;

  ChatBoxCache._internal();

  final Map<String, Box> _cache = {};
  final List<String> _recentKeys = [];

  Future<Box> getBox(String chatId) async {
    if (_cache.containsKey(chatId)) {
      // Move to front to mark as recently used
      _recentKeys.remove(chatId);
      _recentKeys.insert(0, chatId);
      return _cache[chatId]!;
    }

    // Open the box
    Box box = await Hive.openBox(chatId);

    // Add to cache
    _cache[chatId] = box;
    _recentKeys.insert(0, chatId);

    // Limit to 5 entries
    // doesnt matter, as long as box is not closed it stays available and open
    if (_recentKeys.length > 2) {
      String removedKey = _recentKeys.removeLast();
      await _cache[removedKey]?.close(); // Optional: close the box
      _cache.remove(removedKey);
    }

    return box;
  }

  Future<void> closeAll() async {
    for (var box in _cache.values) {
      await box.close();
    }
    _cache.clear();
    _recentKeys.clear();
  }
}
