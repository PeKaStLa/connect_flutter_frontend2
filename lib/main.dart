import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:core'; // For math.cos, math.pow
import 'package:connect_flutter/plugins/zoombuttons.dart';
import 'package:connect_flutter/misc/tile_providers.dart';
import 'package:connect_flutter/widgets/area_details_overlay.dart'; // Import the new widget
import 'package:connect_flutter/models/area_data.dart'; // Import the new area data file
import 'package:connect_flutter/utils/map_utils.dart'; // Import the new utility functions

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

  late MapController mapController;
  // double _markerSize = 60.0; // This will be calculated per marker now
  double _currentZoom = 12.0; // State variable to hold the current zoom level

  Area? _currentlyHoveredArea;
  Area? _currentlyClickedArea;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    // _currentZoom is initialized. It will be updated by onPositionChanged.
  }

  // This function now primarily updates the current zoom and triggers a rebuild
  void _updateCurrentZoom(double? newZoom) {
    if (newZoom == null) return;
    // Only call setState if the zoom has actually changed to avoid unnecessary rebuilds
    if (_currentZoom != newZoom) {
      setState(() {
        _currentZoom = newZoom;
      });
    }
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
        title: Text('${widget.title} - Zoom: ${_currentZoom.toStringAsFixed(2)}'),
      ),
      body: Stack( // Use Stack to overlay widgets
        children: [

      FlutterMap(
        mapController: mapController, // Assign the mapController
        options: MapOptions(
          onPositionChanged: (MapCamera camera, bool hasGesture) {
            _updateCurrentZoom(camera.zoom);
          },
          interactionOptions: const InteractionOptions(
            enableMultiFingerGestureRace: true,
          ),
          initialCenter: const LatLng(-37.8136, 144.9631), // Centered on Melbourne CBD
          initialZoom: 12.0, // Adjusted zoom for better initial view of markers
        ),
        children: [
          openStreetMapTileLayer,
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
            markers: exampleAreas.map((area) {
              // Determine color based on hover state
              final bool isHovered = _currentlyHoveredArea?.name == area.name;
              final bool isClicked = _currentlyClickedArea?.name == area.name;
              final double calculatedMarkerSize = calculateMarkerSizeForArea(area, _currentZoom);

              return Marker(
                point: LatLng(area.centerLatitude, area.centerLongitude),
                width: calculatedMarkerSize,
                height: calculatedMarkerSize,
                child: MouseRegion( // This makes it hoverable
                  onEnter: (event) {
                    if (mounted) { // Check if the state is still mounted
                      setState(() {
                        _currentlyHoveredArea = area;
                        _currentlyClickedArea = null;
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
                      if (mounted) {
                          setState(() {
                            if (_currentlyClickedArea?.name == area.name) { // Check if the tapped area is ALREADY selected
                              _currentlyClickedArea = null; // deselect it
                            } else {
                              _currentlyClickedArea = area; // select it
                            }
                          });
                        }
                      // Immediately hide hover info on tap
                      if (_currentlyHoveredArea != null && mounted) {
                        setState(() {
                          _currentlyHoveredArea = null;
                        });
                      }
                   },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Change color slightly on hover
                        color: Colors.blue.withValues(alpha: isHovered ? 0.7 : isClicked ? 0.7 : 0.5),
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
  
          // Add the ZoomButtons plugin here
          const ZoomButtons(
            minZoom: 4,
            maxZoom: 19,
            mini: true,
            padding: 10,
            alignment: Alignment.bottomRight,
          ),

        ],
      ),
        // Use the new AreaDetailsOverlay widget
        AreaDetailsOverlay(
          currentlyClickedArea: _currentlyClickedArea,
          onChatNavigation: (area) {
            navigateToChat(context, area); // Use extracted function
            // Optionally hide the overlay after navigating
          },
          onClose: () {
            if (mounted) setState(() => _currentlyClickedArea = null);
          },
        ),
        ]
      )
    );
  }
}
