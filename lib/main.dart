import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:logger/logger.dart';
import 'package:latlong2/latlong.dart';
//import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';



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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Map Demo'), // Updated title
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // State variable to track the currently hovered area
  final Logger _logger = Logger();

  // State variable to track the currently hovered area
  Area? _currentlyHoveredArea;
  
  // List of example areas
  final List<Area> _exampleAreas = [
    Area(
      name: "Melbourne CBD",
      centerLatitude: -37.8136,
      centerLongitude: 144.9631,
      minLatitude: -37.8186,
      minLongitude: 144.9581,
      maxLatitude: -37.8086,
      maxLongitude: 144.9681,
      radiusMeter: 1000.0,
    ),
    Area(
      name: "Royal Botanic Gardens",
      centerLatitude: -37.8300,
      centerLongitude: 144.9790,
      minLatitude: -37.8350,
      minLongitude: 144.9740,
      maxLatitude: -37.8250,
      maxLongitude: 144.9840,
      radiusMeter: 750.0,
    ),
    Area(
      name: "Docklands",
      centerLatitude: -37.8170,
      centerLongitude: 144.9420,
      minLatitude: -37.8220,
      minLongitude: 144.9370,
      maxLatitude: -37.8120,
      maxLongitude: 144.9470,
      radiusMeter: 800.0,
    ),
  ];

  // Placeholder for navigation or action when a marker is tapped
  void _navigateToChat(BuildContext context, Area area) {
    _logger.i('Tapped on area: ${area.name}');
    // You can implement navigation or show a dialog here
    ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove previous snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action for: ${area.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(-37.8136, 144.9631), // Centered on Melbourne CBD
          initialZoom: 12.0, // Adjusted zoom for better initial view of markers
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.connect.app', // Replace with your app's package name
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () { /* Handle tap if needed, e.g., open a URL */ },
              ),
            ],
          ),
          // Add the MarkerLayer for clickable and hoverable areas
          MarkerLayer(
            markers: _exampleAreas.map((area) {
              // Determine color based on hover state
              final bool isHovered = _currentlyHoveredArea?.name == area.name;

              return Marker(
                point: LatLng(area.centerLatitude, area.centerLongitude),
                width: 120.0, // Give some extra width/height for the hover hit area
                height: 120.0,
                child: MouseRegion( // This makes it hoverable
                  onEnter: (event) {
                    if (mounted) { // Check if the state is still mounted
                      setState(() {
                        _currentlyHoveredArea = area;
                      });
                    }
                  },
                  onExit: (event) {
                     if (mounted) { // Check if the state is still mounted
                      setState(() {
                        _currentlyHoveredArea = null;
                      });
                    }
                  },
                  child: GestureDetector( // This makes it clickable
                    onTap: () {
                      // Immediately hide hover info on tap
                      if (_currentlyHoveredArea != null && mounted) {
                        setState(() {
                          _currentlyHoveredArea = null;
                        });
                      }
                      _navigateToChat(context, area);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Change color slightly on hover
                        color: Colors.blue.withValues(alpha: isHovered ? 0.7 : 0.5),
                        border: Border.all(color: Colors.blue.shade700, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text( 
                        area.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis, // Handle long names
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12, 
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
