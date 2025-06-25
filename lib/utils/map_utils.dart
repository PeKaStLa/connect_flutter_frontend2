import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:connect_flutter/models/area_data.dart'; // For Area class

// Create a logger instance for this utility file if needed,
// or you could pass a logger instance to functions that need it.
final Logger _mapUtilsLogger = Logger();

// Global cache for marker sizes: key is area.id, value is marker size
final Map<String, double> _markerSizeCache = {};
final Map<String, DateTime> _markerSizeCacheTime = {};

double calculateMarkerSizeForArea(Area area, double currentZoom) {
  final cacheKey = area.id.toString(); // Use area.id as the key
  final now = DateTime.now();

  // Check if we have a cached value and it's not older than 10ms
  if (_markerSizeCache.containsKey(cacheKey) &&
      _markerSizeCacheTime.containsKey(cacheKey) &&
      now.difference(_markerSizeCacheTime[cacheKey]!).inMilliseconds < 16) {
    return _markerSizeCache[cacheKey]!;
  }

  double calculatedSize = 0.000008 * area.radiusMeter * math.pow(2, currentZoom);

  // Save to cache and update timestamp
  _markerSizeCache[cacheKey] = calculatedSize;
  _markerSizeCacheTime[cacheKey] = now;

  return calculatedSize;
}


// show snackbar for 4-5 seconds...
void snackbar(BuildContext context, String message) {
  _mapUtilsLogger.i('Action for: $message');
  ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove previous snackbar
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(message)), );
}
