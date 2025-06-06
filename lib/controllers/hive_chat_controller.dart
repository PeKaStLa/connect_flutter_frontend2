import 'dart:async';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:hive_ce/hive.dart';
import 'package:connect_flutter/services/chat_box_cache_class.dart'; // Import your service

class HiveChatController
    with UploadProgressMixin, ScrollToMessageMixin
    implements ChatController {
  late final Box _box;
  final String _boxName;
  final _operationsController = StreamController<ChatOperation>.broadcast();

  // Cache for performance - invalidated when data changes
  List<Message>? _cachedMessages;

  /// Creates a HiveChatController.
  /// [chatId] is used to create a unique box name for this chat instance.
  /// It's recommended to sanitize [chatId] if it comes from user input or
  /// could contain characters not suitable for file names.
  HiveChatController({required String chatId}) : _boxName = chatId;

  /// Initializes the controller by opening its specific Hive box.
  /// This must be called before using the controller.
  Future<void> init() async {
    // Hive.initFlutter() should have been called once in main.dart
    _box = await ChatBoxCache().getBox(_boxName);
    // _box = await Hive.openBox(_boxName);
    // Emit an initial state to ensure the Chat widget loads existing messages.
    if (_box.isNotEmpty && messages.isNotEmpty) { // Accessing messages getter will load from _box
      _operationsController.add(ChatOperation.set(messages));
    } else {
      _operationsController.add(ChatOperation.set([])); // Emit empty if box is new or empty
    }
  }

  /// Returns the name of the Hive box being used by this controller.
  String get boxName => _box.isOpen ? _box.name : _boxName; // Return _boxName if not yet open

  @override
  Future<void> insertMessage(Message message, {int? index}) async {
    if (!_box.isOpen) throw StateError('Hive box $_boxName is not open. Call init() first.');
    if (_box.containsKey(message.id)) return;

    // Index is ignored because Hive does not maintain order
    await _box.put(message.id, message.toJson());
    _invalidateCache();
    _operationsController.add(ChatOperation.insert(message, _box.length - 1));
  }

  @override
  Future<void> removeMessage(Message message) async {
    if (!_box.isOpen) throw StateError('Hive box $_boxName is not open. Call init() first.');
    final sortedMessages = List.from(messages);
    final index = sortedMessages.indexWhere((m) => m.id == message.id);

    if (index != -1) {
      final messageToRemove = sortedMessages[index];
      await _box.delete(messageToRemove.id);
      _invalidateCache();
      _operationsController.add(ChatOperation.remove(messageToRemove, index));
    }
  }

  @override
  Future<void> updateMessage(Message oldMessage, Message newMessage) async {
    if (!_box.isOpen) throw StateError('Hive box $_boxName is not open. Call init() first.');
    final sortedMessages = List.from(messages);
    final index = sortedMessages.indexWhere((m) => m.id == oldMessage.id);

    if (index != -1) {
      final actualOldMessage = sortedMessages[index];

      if (actualOldMessage == newMessage) {
        return;
      }

      await _box.put(actualOldMessage.id, newMessage.toJson());
      _invalidateCache();
      _operationsController.add(
        ChatOperation.update(actualOldMessage, newMessage, index),
      );
    }
  }

  @override
  Future<void> setMessages(List<Message> messages) async {
    if (!_box.isOpen) throw StateError('Hive box $_boxName is not open. Call init() first.');
    await _box.clear();
    if (messages.isEmpty) {
      _invalidateCache();
      _operationsController.add(ChatOperation.set([]));
      return;
    } else {
      await _box.putAll(
        messages
            .map((message) => {message.id: message.toJson()})
            .toList()
            .reduce((acc, map) => {...acc, ...map}),
      );
      _invalidateCache();
      _operationsController.add(ChatOperation.set(messages));
    }
  }

  @override
  Future<void> insertAllMessages(List<Message> messages, {int? index}) async {
    if (!_box.isOpen) throw StateError('Hive box $_boxName is not open. Call init() first.');
    if (messages.isEmpty) return;

    // Index is ignored because Hive does not maintain order
    final originalLength = _box.length;
    await _box.putAll(
      messages
          .map((message) => {message.id: message.toJson()})
          .toList()
          .reduce((acc, map) => {...acc, ...map}),
    );
    _invalidateCache();
    _operationsController.add(
      ChatOperation.insertAll(messages, originalLength),
    );
  }

  /// Invalidates the cached messages list
  void _invalidateCache() {
    _cachedMessages = null;
  }

  @override
  List<Message> get messages {
    if (!_box.isOpen) {
      // This case should ideally not be hit if init() is called and dispose() is managed.
      return [];
    }
    if (_cachedMessages != null) {
      return _cachedMessages!;
    }

    _cachedMessages =
        _box.values.map((json) => Message.fromJson(_convertMap(json))).toList()
          ..sort(
            (a, b) => (a.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
              b.createdAt?.millisecondsSinceEpoch ?? 0,
            ),
          );

    return _cachedMessages!;
  }

  @override
  Stream<ChatOperation> get operationsStream => _operationsController.stream;

  @override
  Future<void> dispose() async {
    _operationsController.close();
    disposeUploadProgress();
    disposeScrollMethods();
    if (_box.isOpen) {
      await _box.close();
    }
  }
}

// ignore: unintended_html_in_doc_comment
/// Efficient type conversion for Map<dynamic, dynamic> to Map<String, dynamic>
Map<String, dynamic> _convertMap(dynamic map) {
  if (map is Map<String, dynamic>) {
    return map;
  }
  return Map<String, dynamic>.from(map);
}