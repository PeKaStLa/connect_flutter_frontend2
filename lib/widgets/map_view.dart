import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'dart:math';
import 'package:connect_flutter/models/area_data.dart';
import 'package:connect_flutter/utils/map_utils.dart';
import 'package:connect_flutter/services/pocketbase.dart' as pocketbase_service;
import 'package:logger/logger.dart';
import 'package:connect_flutter/widgets/area_details_overlay.dart';
import 'package:connect_flutter/widgets/area_chat_overlay.dart';
import 'package:connect_flutter/plugins/zoombuttons.dart';
import 'package:connect_flutter/utils/tile_providers.dart';

class MapView extends StatefulWidget {
  final double currentZoom;
  final Function(double?) onZoomChanged;
  final Logger logger;

  const MapView({
    super.key,
    required this.currentZoom,
    required this.onZoomChanged,
    required this.logger,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late MapController mapController;
  double _currentZoom = 12.0;
  Area? _currentlyDetailedArea;
  Area? _currentlyColoredArea;
  Area? _currentlyChattedArea;
  List<Area> _mapAreas = [];
  bool _isLoadingAreas = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _fetchMapAreas();
    _centerMapOnUserLocation();
    _currentZoom = widget.currentZoom;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _centerMapOnUserLocation() async {
    try {
      final position = await _determinePosition();
      mapController.move(LatLng(position.latitude, position.longitude), _currentZoom);
      widget.logger.i("Centered map on user's current location: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      widget.logger.e("Error getting current location: $e");
    }
  }

  void _adjustMapCenter(double areaLatitude, double areaLongitude, double areaRadius) {
    if (!mounted) {
      widget.logger.w("_adjustMapCenter: Widget not mounted, cannot adjust map center.");
      return;
    }
    final double newZoom = (-1.425 * log(areaRadius) + 24.135);
    double offset = (0.23) * (1 / pow(2, newZoom - 10));
    LatLng newCenter = LatLng(areaLatitude - offset, areaLongitude);
    mapController.move(newCenter, newZoom);
  }

  Future<void> _fetchMapAreas() async {
    widget.logger.d("_fetchMapAreas started. mounted: $mounted");
    if (!mounted) {
      widget.logger.w("_fetchMapAreas: widget not mounted, returning.");
      return;
    }

    setState(() {
      _isLoadingAreas = true;
      _loadingError = null;
      widget.logger.d("_fetchMapAreas: setState called, _isLoadingAreas = true");
    });

    try {
      widget.logger.i("Attempting to fetch areas from pocketbase_service...");
      final records = await pocketbase_service.getAreas();
      widget.logger.i("Successfully fetched ${records.length} records from PocketBase.");

      if (!mounted) {
        widget.logger.w("_fetchMapAreas: widget not mounted after fetching records, returning.");
        return;
      }

      widget.logger.i("Mapping records to Area objects...");
      final areas = records.map((record) {
        widget.logger.d("Mapping record ID: ${record.id}");
        try {
          return Area.fromRecord(record);
        } catch (e, s) {
          widget.logger.e("Error in Area.fromRecord for ID ${record.id}", error: e, stackTrace: s);
          rethrow;
        }
      }).toList();
      widget.logger.i("Successfully mapped ${areas.length} Area objects.");

      if (mounted) {
        setState(() {
          _mapAreas = areas;
          widget.logger.d("_fetchMapAreas: setState called, _mapAreas updated with ${areas.length} areas.");
        });
      } else {
        widget.logger.w("_fetchMapAreas: widget not mounted before final setState for _mapAreas.");
      }
    } catch (e, stackTrace) {
      widget.logger.e("Error in _fetchMapAreas", error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _loadingError = "Failed to load areas: $e";
          widget.logger.d("_fetchMapAreas: setState called, _loadingError updated.");
        });
      } else {
        widget.logger.w("_fetchMapAreas: widget not mounted when handling error.");
      }
    } finally {
      widget.logger.d("_fetchMapAreas: finally block executing. mounted: $mounted");
      if (mounted) {
        setState(() {
          _isLoadingAreas = false;
          widget.logger.d("_fetchMapAreas: setState called in finally, _isLoadingAreas = false");
        });
      } else {
        widget.logger.w("_fetchMapAreas: widget not mounted in finally block.");
      }
      widget.logger.d("_fetchMapAreas finished.");
    }
  }

  void _handleZoomChanged(double? newZoom) {
    if (newZoom == null) return;
    if (_currentZoom != newZoom) {
      setState(() {
        _currentZoom = newZoom;
      });
      widget.onZoomChanged(newZoom);
    }
  }

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
            setState(() {
              if (_currentlyDetailedArea?.name != area.name) {
                _currentlyDetailedArea = area;
                _currentlyColoredArea = area;
                _currentlyChattedArea = null;
              } else if (_currentlyDetailedArea?.name == area.name) {
                _currentlyChattedArea = area;
                _adjustMapCenter(area.centerLatitude, area.centerLongitude, area.radiusMeter);
              }
            });
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
    if (_isLoadingAreas) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadingError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: $_loadingError', style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            onPositionChanged: (MapCamera camera, bool hasGesture) {
              _handleZoomChanged(camera.zoom);
            },
            onTap: (_, __) {
              setState(() {
                _currentlyDetailedArea = _currentlyChattedArea = _currentlyColoredArea = null;
              });
            },
            interactionOptions: const InteractionOptions(
              enableMultiFingerGestureRace: true,
            ),
            initialCenter: const LatLng(-37.8136, 144.9631),
            initialZoom: 12.0,
          ),
          children: [
            openStreetMapTileLayer,
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () {},
                ),
              ],
            ),
            MarkerLayer(
              markers: _mapAreas.map(_buildAreaMarker).toList(),
            ),
            ZoomButtons(
              minZoom: 4,
              maxZoom: 19,
              mini: true,
              padding: 10,
              alignment: Alignment.bottomRight,
              onCompassNorthPressed: _centerMapOnUserLocation,
),
          CurrentLocationLayer(),          
          ],
        ),
        if (_currentlyDetailedArea != null)
          AreaDetailsOverlay(
            area: _currentlyDetailedArea,
            onChatNavigation: (area) {
              setState(() {
                _currentlyChattedArea = area;
              });
              _adjustMapCenter(area.centerLatitude, area.centerLongitude, area.radiusMeter);
            },
          ),
        if (_currentlyChattedArea != null)
          AreaChatOverlay(
            key: ValueKey(_currentlyChattedArea!.name),
            area: _currentlyChattedArea!,
            pb: pocketbase_service.pb,
            onClose: () {
              setState(() {
                _currentlyChattedArea = null;
              });
            },
          ),
      ],
    );
  }
}