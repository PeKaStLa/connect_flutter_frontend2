import 'package:pocketbase/pocketbase.dart'; // Import PocketBase
import 'package:logger/logger.dart'; // Import the logger package

final Logger _logger = Logger(); // Initialize a logger for this file

// Define the Area class
class Area {
  final double centerLatitude;
  final double centerLongitude;
  final double? minLatitude;  // Make nullable
  final double? minLongitude; // Make nullable
  final double? maxLatitude;  // Make nullable
  final double? maxLongitude; // Make nullable
  final String name;
  final String id;
  final double radiusMeter;

  Area({
    required this.centerLatitude,
    required this.centerLongitude,
    this.minLatitude,   // Remove required, allow null
    this.minLongitude,  // Remove required, allow null
    this.maxLatitude,   // Remove required, allow null
    this.maxLongitude,  // Remove required, allow null
    required this.id,
    required this.name,
    required this.radiusMeter,
  });


  factory Area.fromRecord(RecordModel record) {
    final data = record.data;
    _logger.i('Creating Area from Record ID: ${record.id}, Data: $data'); // Log the received data

    return Area(
      id: record.id, 
      name: data['area_name'] as String? ?? 'Unnamed Area',
      centerLatitude: double.tryParse(data['center_latitude']?.toString() ?? '') ?? 0.0,
      centerLongitude: double.tryParse(data['center_longitude']?.toString() ?? '') ?? 0.0,
      radiusMeter: double.tryParse(data['radius_meter']?.toString() ?? '') ?? 1000.0,
      // Optionally map min/max if they exist in your PocketBase data
      minLatitude: double.tryParse(data['min_latitude'].toString()),
      minLongitude: double.tryParse(data['min_longitude'].toString()),
      maxLatitude: double.tryParse(data['max_latitude'].toString()),
      maxLongitude:double.tryParse(data['max_longitude'].toString()),
    );
  }
}
