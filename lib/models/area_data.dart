// Define the Area class
class Area {
  final double centerLatitude;
  final double centerLongitude;
  final double minLatitude;
  final double minLongitude;
  final double maxLatitude;
  final double maxLongitude;
  final String name;
  final double radiusMeter;

  Area({
    required this.centerLatitude,
    required this.centerLongitude,
    required this.minLatitude,
    required this.minLongitude,
    required this.maxLatitude,
    required this.maxLongitude,
    required this.name,
    required this.radiusMeter,
  });
}

// List of example areas
final List<Area> exampleAreas = [
  Area(
    name: "Melbourne CBD",
    centerLatitude: -37.8136,
    centerLongitude: 144.9631,
    minLatitude: -37.8186,
    minLongitude: 144.9581,
    maxLatitude: -37.8086,
    maxLongitude: 144.9681,
    radiusMeter: 1931.0,
  ),
  Area(
    name: "Royal Botanic Gardens",
    centerLatitude: -37.8300,
    centerLongitude: 144.9790,
    minLatitude: -37.8350,
    minLongitude: 144.9740,
    maxLatitude: -37.8250,
    maxLongitude: 144.9840,
    radiusMeter: 805.0,
  ),
  Area(
    name: "Docklands",
    centerLatitude: -37.8170,
    centerLongitude: 144.9420,
    minLatitude: -37.8220,
    minLongitude: 144.9370,
    maxLatitude: -37.8120,
    maxLongitude: 144.9470,
    radiusMeter: 1610.0,
  ),
];