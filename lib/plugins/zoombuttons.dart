import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:connect_flutter/plugins/compass.dart'; // Import the new widget

class ZoomButtons extends StatelessWidget {
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
  final double spaceBetweenButtons;

  const ZoomButtons({
    super.key,
    this.minZoom = 1,
    this.maxZoom = 18,
    this.mini = true,
    this.padding = 0,
    this.alignment = Alignment.bottomRight, // Default to bottom-right
    this.zoomInColor,
    this.zoomInColorIcon,
    this.zoomInIcon = Icons.zoom_in,
    this.zoomOutColor,
    this.zoomOutColorIcon,
    this.zoomOutIcon = Icons.zoom_out,
    this.exploreIcon = Icons.explore,
    this.navigationIcon = Icons.navigation,
    this.spaceBetweenButtons = 0, // Default small spacing between buttons
  });

  @override
  Widget build(BuildContext context) {
    final controller = MapController.of(context);
    final camera = MapCamera.of(context);
    final theme = Theme.of(context);

    return Align(
      alignment: alignment,
      child: Padding( // This Padding controls the distance of the whole button group from the corner
        padding: EdgeInsets.all(padding), // Use the main 'padding' property here
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'setRotationToZeroButton',
              mini: mini,
              backgroundColor: zoomInColor ?? theme.colorScheme.primary,
              onPressed: () {
                controller.rotate(0);
              },
              child: (camera.rotation.abs() < 0.001) // More robust check for 0 rotation
                  ? Icon(navigationIcon, color: zoomInColorIcon ?? theme.iconTheme.color)
                  : const CustomMapCompass( // Added const
                      hideIfRotatedNorth: true,
                    ),
            ),
            SizedBox(height: spaceBetweenButtons), // Use SizedBox for spacing
            FloatingActionButton(
              heroTag: 'zoomInButton',
              mini: mini,
              backgroundColor: zoomInColor ?? theme.colorScheme.primary,
              onPressed: () {
                final zoom = min(camera.zoom + 1, maxZoom);
                controller.move(camera.center, zoom);
              },
              child: Icon(zoomInIcon, color: zoomInColorIcon ?? theme.iconTheme.color),
            ),
            SizedBox(height: spaceBetweenButtons), // Use SizedBox for spacing
            FloatingActionButton(
              heroTag: 'zoomOutButton',
              mini: mini,
              backgroundColor: zoomOutColor ?? theme.colorScheme.primary,
              onPressed: () {
                final zoom = max(camera.zoom - 1, minZoom);
                controller.move(camera.center, zoom);
              },
              child: Icon(zoomOutIcon, color: zoomOutColorIcon ?? theme.iconTheme.color),
            ),
          ],
        ),
      ),
    );
  }
}