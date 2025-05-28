import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:flutter/cupertino.dart'; // For CupertinoIcons

class FlutterMapZoomButtons extends StatelessWidget {
  final double minZoom;
  final double maxZoom;
  final bool mini;
  final double padding;
  final Alignment alignment;
  final Color? zoomInColor;
  final Color? zoomInColorIcon;
  final Color? zoomOutColor;
  final Color? zoomOutColorIcon;
  final IconData zoomInIcon;
  final IconData zoomOutIcon;
  final IconData exploreIcon;
  final IconData navigationIcon;
  final double compassIconSize;

  const FlutterMapZoomButtons({
    super.key,
    this.minZoom = 1,
    this.maxZoom = 18,
    this.mini = true,
    this.padding = 2.0,
    this.alignment = Alignment.topRight,
    this.zoomInColor,
    this.zoomInColorIcon,
    this.zoomInIcon = Icons.zoom_in,
    this.zoomOutColor,
    this.zoomOutColorIcon,
    this.zoomOutIcon = Icons.zoom_out,
    this.exploreIcon = Icons.explore,
    this.navigationIcon = Icons.navigation,
    this.compassIconSize = 39, // Default compass icon size
  });

  @override
  Widget build(BuildContext context) {
    final controller = MapController.of(context);
    final camera = MapCamera.of(context);
    final theme = Theme.of(context);

    return Align(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(left: padding, top: padding, right: padding),
            child: FloatingActionButton(
              heroTag: 'setRotationToZeroButton',
              mini: mini,
              backgroundColor: zoomInColor ?? theme.primaryColor,
              onPressed: () {
                controller.rotate(0);
              },
              child: MapCompass(
                hideIfRotatedNorth: true,
                rotationOffset: -45, // Specific to Cupertino-style compass
                alignment: Alignment.center, //Center the icon within the FAB
                padding: EdgeInsets.only(left: 0), // Let FAB padding and size control spacing
                icon: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // The order matters for stacking: first is bottom, last is top.
                    // CupertinoIcons.circle is an outline, so it can act as a border.
                    // The original MapCompass.cupertino puts circle last, which means it's drawn on top.
                    Icon(CupertinoIcons.compass, color: Colors.red, size: compassIconSize-1),
                    Icon(CupertinoIcons.compass_fill, color: Colors.white54, size: compassIconSize-2),
                    Icon(CupertinoIcons.circle, color: Colors.black, size: compassIconSize),
                  ],
                ),
                // onPressed is handled by the FAB, MapCompass will use its default
                // behavior (rotate to North) due to onPressedOverridesDefault = true by default.
                // If you want MapCompass to be non-interactive visually:
                // onPressed: null,
                // onPressedOverridesDefault: false,
              ),
            ),
          ),


          Padding(
            padding:
                EdgeInsets.only(left: padding, top: padding, right: padding),
            child: FloatingActionButton(
              heroTag: 'zoomInButton',
              mini: mini,
              backgroundColor: zoomInColor ?? theme.primaryColor,
              onPressed: () {
                final zoom = min(camera.zoom + 1, maxZoom);
                controller.move(camera.center, zoom);
              },
              child: Icon(zoomInIcon,
                  color: zoomInColorIcon ?? theme.iconTheme.color),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(padding),
            child: FloatingActionButton(
              heroTag: 'zoomOutButton',
              mini: mini,
              backgroundColor: zoomOutColor ?? theme.primaryColor,
              onPressed: () {
                final zoom = max(camera.zoom - 1, minZoom);
                controller.move(camera.center, zoom);
              },
              child: Icon(zoomOutIcon,
                  color: zoomOutColorIcon ?? theme.iconTheme.color),
            ),
          ),
        ],
      ),
    );
  }
}