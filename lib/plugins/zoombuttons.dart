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

  const ZoomButtons({
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
              backgroundColor: zoomInColor ?? theme.colorScheme.primary,
              onPressed: () {
                controller.rotate(0);
              },
              child: (camera.rotation == 0)
              ? Icon(navigationIcon , color: zoomInColorIcon ?? theme.iconTheme.color)
              : CustomMapCompass(
                hideIfRotatedNorth: true,
                // alignment and padding are handled by the FAB and the CustomCupertinoMapCompass defaults
                // or can be overridden if needed when calling CustomCupertinoMapCompass.
                // For this specific use inside a FAB, the defaults are likely fine.
              ),
            ),
          ),


          Padding(
            padding:
                EdgeInsets.only(left: padding, top: padding, right: padding),
            child: FloatingActionButton(
              heroTag: 'zoomInButton',
              mini: mini,
              backgroundColor: zoomInColor ?? theme.colorScheme.primary,
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
              backgroundColor: zoomOutColor ?? theme.colorScheme.primary,
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