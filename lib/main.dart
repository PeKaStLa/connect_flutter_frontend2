import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'dart:core'; // For math.cos, math.pow
import 'package:connect_flutter/plugins/zoombuttons.dart';
import 'package:connect_flutter/misc/tile_providers.dart';
import 'package:connect_flutter/widgets/area_details_overlay.dart'; // Import the new widget
import 'package:connect_flutter/models/area_data.dart'; // Import the new area data file
import 'package:connect_flutter/utils/map_utils.dart'; // Import the new utility functions
import 'package:connect_flutter/widgets/area_chat_overlay.dart'; // Import the chat overlay
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:connect_flutter/services/pocketbase.dart' as pocketbase_service; // Import your service
import 'package:logger/logger.dart'; // Import the logger package

void main() async {
  await Hive.initFlutter(); // Initialize Hive for Flutter
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

  // Use the pb instance from your service file if you want to share it,
  // or keep a local one if preferred for this widget.
  // For this example, we'll use the one from the service for fetching areas.
  late MapController mapController;
  double _currentZoom = 12.0; // State variable to hold the current zoom level
  Area? _currentlyDetailedArea;
  Area? _currentlyColoredArea;
  Area? _currentlyChattedArea; // State to manage which area's chat is open
  List<Area> _mapAreas = []; // To store areas fetched from PocketBase
  bool _isLoadingAreas = true; // To manage loading state
  String? _loadingError; // To store any error message during loading
  final Logger _logger = Logger(); // Initialize a logger for this state

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    
    // _currentZoom is initialized. It will be updated by onPositionChanged.
    _fetchMapAreas();
  }


void _adjustMapCenter(double areaLatitude, double areaLongitude) {
  if (!mounted) {
    _logger.w("_adjustMapCenter: Widget not mounted, cannot adjust map center.");
    return;
  }

  final LatLng currentCenter = mapController.camera.center;
  final double currentZoom = mapController.camera.zoom;
  // Calculate the offset in latitude degrees
  double offset = (0.26) * (1 / pow(2, currentZoom - 10));
  // Calculate the new center point
  LatLng newCenter = LatLng(areaLatitude - offset, areaLongitude);
  mapController.move(newCenter, currentZoom);
  snackbar(context, ' changed from oldCenter: $currentCenter to newCenter: $newCenter'); // Use extracted function
}



  Future<void> _fetchMapAreas() async {
    _logger.d("_fetchMapAreas started. mounted: $mounted");
    if (!mounted) {
      _logger.w("_fetchMapAreas: widget not mounted, returning.");
      return;
    }

    setState(() {
      _isLoadingAreas = true;
      _loadingError = null;
      _logger.d("_fetchMapAreas: setState called, _isLoadingAreas = true");
    });

    try {
      _logger.i("Attempting to fetch areas from pocketbase_service...");
      final records = await pocketbase_service.getAreas();
      _logger.i("Successfully fetched ${records.length} records from PocketBase.");

      if (!mounted) {
        _logger.w("_fetchMapAreas: widget not mounted after fetching records, returning.");
        return;
      }

      _logger.i("Mapping records to Area objects...");
      final areas = records.map((record) {
        _logger.d("Mapping record ID: ${record.id}");
        try {
          return Area.fromRecord(record);
        } catch (e, s) {
          _logger.e("Error in Area.fromRecord for ID ${record.id}", error: e, stackTrace: s);
          rethrow; // Propagate error to be caught by the outer try-catch
        }
      }).toList();
      _logger.i("Successfully mapped ${areas.length} Area objects.");

      if (mounted) {
        setState(() {
          _mapAreas = areas;
          _logger.d("_fetchMapAreas: setState called, _mapAreas updated with ${areas.length} areas.");
        });
      } else {
         _logger.w("_fetchMapAreas: widget not mounted before final setState for _mapAreas.");
      }
    } catch (e, stackTrace) {
      _logger.e("Error in _fetchMapAreas", error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _loadingError = "Failed to load areas: $e";
          _logger.d("_fetchMapAreas: setState called, _loadingError updated.");
        });
      } else {
        _logger.w("_fetchMapAreas: widget not mounted when handling error.");
      }
    } finally {
      _logger.d("_fetchMapAreas: finally block executing. mounted: $mounted");
      if (mounted) {
        setState(() {
          _isLoadingAreas = false;
          _logger.d("_fetchMapAreas: setState called in finally, _isLoadingAreas = false");
        });
      } else {
        _logger.w("_fetchMapAreas: widget not mounted in finally block.");
      }
      _logger.d("_fetchMapAreas finished.");
    }
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
    bool isColored = _currentlyColoredArea?.name == area.name;
    
    final double calculatedMarkerSize = calculateMarkerSizeForArea(area, _currentZoom);

    return Marker(
      point: LatLng(area.centerLatitude, area.centerLongitude),
      width: calculatedMarkerSize,
      height: calculatedMarkerSize,
      child: MouseRegion(
        child: GestureDetector(
          onTap: () {
            if (mounted) {
              setState(() {

                if (_currentlyDetailedArea?.name != area.name) {
                  _currentlyDetailedArea = area;
                  _currentlyColoredArea = area;
                  _currentlyChattedArea = null;
                } else if (_currentlyDetailedArea?.name == area.name) {
                  _currentlyChattedArea = area;
                  _adjustMapCenter(area.centerLatitude, area.centerLongitude); // Pass lat and long separately
                }
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withAlpha(isColored ? 210 : 100),
              border: Border.all(color: Colors.blue.shade700, width: isColored ? 3 : 2),
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
      body: _isLoadingAreas
          ? const Center(child: CircularProgressIndicator())
          : _loadingError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $_loadingError', style: const TextStyle(color: Colors.red)),
                  ))
              : 
         Stack( // Use Stack to overlay widgets
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
                _currentlyDetailedArea = _currentlyChattedArea = _currentlyColoredArea = null;
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
            markers: _mapAreas.map(_buildAreaMarker).toList(), // Use fetched areas
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
          area: _currentlyDetailedArea,
          onChatNavigation: (area) {
            snackbar(context, area.name); // Use extracted function
                if (mounted) {
                  setState(() {
                    _currentlyChattedArea = area;
                  });
                }          
          },
          // onClose: () {  if (mounted) setState(() => _currentlyDetailedArea = null);  },
        ),
          // Conditionally display MapChatOverlay
          if (_currentlyChattedArea != null)
            AreaChatOverlay(
              key: ValueKey(_currentlyChattedArea!.name), 
              area: _currentlyChattedArea!,
              pb: pocketbase_service.pb, // Pass the PocketBase instance
              onClose: () {
                if (mounted) setState(() => _currentlyChattedArea = null);
                },
            ),
        ]
      )
    );
  }
}
