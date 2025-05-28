import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';


class CustomMapCompass extends StatelessWidget {
  final double iconSize;
  final bool hideIfRotatedNorth;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;

  const CustomMapCompass({
    super.key,
    this.iconSize = 39.0, // Default size, matches your previous default
    this.hideIfRotatedNorth = true,
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.all(0)
  });

  @override
  Widget build(BuildContext context) {
    return MapCompass(
      hideIfRotatedNorth: hideIfRotatedNorth,
      rotationOffset: -45, // Specific to Cupertino-style compass
      alignment: alignment,
      padding: EdgeInsets.zero,
      icon: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // The order matters for stacking: first is bottom, last is top.
          // CupertinoIcons.circle is an outline, so it can act as a border.
          // The original MapCompass.cupertino puts circle last, which means it's drawn on top.
          Icon(CupertinoIcons.compass, color: Colors.red, size: iconSize - 1),
          Icon(CupertinoIcons.compass_fill, color: Colors.white54, size: iconSize - 2),
          Icon(CupertinoIcons.circle, color: Colors.black, size: iconSize),
        ],
      ),
      // onPressed behavior for the MapCompass itself.
      // If this widget is a direct child of a FAB that handles onPressed,
      // you might want to make MapCompass non-interactive by setting:
      // onPressed: null,
      // onPressedOverridesDefault: false,
      // However, for general use, letting it default is often fine.
    );
  }
}
