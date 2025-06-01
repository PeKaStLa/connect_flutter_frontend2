import 'dart:math'; // math.Random is in dart:math, not math.dart
// No need to import Flutter/Material if not used directly in this file for UI

// Helper function to generate a random alphanumeric ID
String generateMessageId(int length) { // Renamed from _generateMessageId to make it public
  const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final Random random = Random();
  return String.fromCharCodes(Iterable.generate(
    length,
    (_) => chars.codeUnitAt(random.nextInt(chars.length)),
  ));
}
