import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:connect_flutter/models/area_data.dart'; // For Area class

// Create a logger instance for this utility file if needed,
// or you could pass a logger instance to functions that need it.
final Logger _mapUtilsLogger = Logger();

double calculateMarkerSizeForArea(Area area, double currentZoom) {
  // The formula might need adjustment if area.radiusMeter is very large or small
  // to ensure calculatedSize remains within a reasonable range for display.
  double calculatedSize = 0.000008 * area.radiusMeter * math.pow(2, currentZoom);
  // Consider re-adding clamping if sizes can become too extreme:
  // return calculatedSize.clamp(20.0, 200.0);
  return calculatedSize;
}


// show snackbar for 4-5 seconds...
void snackbar(BuildContext context, String message) {
  _mapUtilsLogger.i('Action for: $message');
  ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove previous snackbar
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('snackbar for: $message')), );
}
