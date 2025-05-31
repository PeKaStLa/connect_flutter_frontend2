import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:core'; // For math.cos, math.pow
import 'package:connect_flutter/plugins/zoombuttons.dart';
import 'package:connect_flutter/misc/tile_providers.dart';
import 'package:connect_flutter/widgets/area_details_overlay.dart'; // Import the new widget
import 'package:connect_flutter/models/area_data.dart'; // Import the new area data file
import 'package:connect_flutter/utils/map_utils.dart'; // Import the new utility functions
import 'package:connect_flutter/widgets/area_chat_overlay.dart'; // Import the chat overlay
import 'package:pocketbase/pocketbase.dart';

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
  final pb = PocketBase('https://my-pb-318455951907.australia-southeast2.run.app');
  double _currentZoom = 12.0; // State variable to hold the current zoom level
  Area? _currentlyHoveredArea;
  Area? _currentlyClickedArea;
  Area? _chattingInArea; // State to manage which area's chat is open

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

  // Extracted function to build a single area marker
  Marker _buildAreaMarker(Area area) {
    final bool isHovered = _currentlyHoveredArea?.name == area.name;
    final bool isClicked = _currentlyClickedArea?.name == area.name;
    final double calculatedMarkerSize = calculateMarkerSizeForArea(area, _currentZoom);

    return Marker(
      point: LatLng(area.centerLatitude, area.centerLongitude),
      width: calculatedMarkerSize,
      height: calculatedMarkerSize,
      child: MouseRegion(
        onEnter: (event) {
          if (mounted) {
            setState(() {
              _currentlyHoveredArea = area;
              // _currentlyClickedArea = null; // Keep clicked area selected on hover
            });
          }
        },
        onExit: (event) {
          if (mounted) {
            setState(() {
              _currentlyHoveredArea = null;
            });
          }
        },
        child: GestureDetector(
          onTap: () {
            if (mounted) {
              setState(() {
                if (_currentlyClickedArea?.name == area.name) {
                  _currentlyClickedArea = null; // Deselect if tapped again
                } else if (_currentlyClickedArea?.name != area.name) {
                  _currentlyClickedArea = area; // Select this new area
                }

                if (_chattingInArea != null) {
                  _chattingInArea = area;          
                }

                _currentlyHoveredArea = null; // Clear hover state on tap
              
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withAlpha(isClicked ? 200 : isHovered ? 120 : 100),
              border: Border.all(color: Colors.blue.shade700, width: isClicked ? 3 : 2),
            ),
            alignment: Alignment.center,
            child: Text(
              area.name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ),
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
          
          onTap: (_, __) { // Add onTap to map to potentially close overlays
            if (mounted) {
              setState(() {
                // Close both overlays if map is tapped
                // _currentlyClickedArea = null;
                // _chattingInArea = null;
                // Or, only close chat if it's open, otherwise close details
                if (_chattingInArea == null && _currentlyClickedArea != null) {
                  _currentlyClickedArea = null;
                } else if (_chattingInArea != null && _currentlyClickedArea != null) {
                  _chattingInArea = null;
                } 
                
              });
            }
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
            markers: exampleAreas.map(_buildAreaMarker).toList(),
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
                if (mounted) {
                  setState(() {
                    _chattingInArea = area;
                  });
                }          },
          onClose: () {
            if (mounted) setState(() => _currentlyClickedArea = null);
          },
        ),
          // Conditionally display MapChatOverlay
          if (_chattingInArea != null)
            AreaChatOverlay(
              area: _chattingInArea!,
              pb: pb,
              onClose: () {
                if (mounted) {
                  setState(() {
                    _chattingInArea = null;
                  });
                }
              },
            ),
        ]
      )
    );
  }
}
