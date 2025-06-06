import 'package:flutter/material.dart';
import 'package:connect_flutter/models/area_data.dart'; // For the Area class

class AreaDetailsOverlay extends StatelessWidget {
  final Area? area;
  final Function(Area) onChatNavigation; // This callback expects a non-null Area
  final VoidCallback? onClose;

  const AreaDetailsOverlay({
    super.key,
    required this.area,
    required this.onChatNavigation,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {

    if (area == null) {
      return const SizedBox.shrink(); // Render nothing if area is null
    }

    // The UI structure is moved here from _buildAreaDetailsOverlay
    return Positioned(
      top: 5.0, // You might want to make these configurable too
      left: 5.0,
      right: 5.0,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
            children: [
              Expanded(
                child: Text(
                  'Area: ${area?.name}\nUsers in area: 12345', // Use currentArea (non-null)
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(height: 1.3),
                ),
              ),
              const SizedBox(width: 8), // Add some space between text and buttons
              TextButton(
                onPressed: () {
                  onChatNavigation(area!); // Pass the non-null currentArea
                },
                child: const Text('Chat'),
              ),
              // IconButton( icon: const Icon(Icons.close), onPressed: onClose, tooltip: 'Close', ),
            ],
          ),
        ),
      ),
    );
  }
}
