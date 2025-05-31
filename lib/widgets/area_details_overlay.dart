import 'package:flutter/material.dart';
import 'package:connect_flutter/models/area_data.dart'; // For the Area class

class AreaDetailsOverlay extends StatelessWidget {
  final Area? currentlyClickedArea;
  final Function(Area) onChatNavigation;
  final VoidCallback onClose;

  const AreaDetailsOverlay({
    super.key,
    required this.currentlyClickedArea,
    required this.onChatNavigation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (currentlyClickedArea == null) {
      return const SizedBox.shrink(); // Return an empty widget if no area is clicked
    }

    // The UI structure is moved here from _buildAreaDetailsOverlay
    return Positioned(
      bottom: 55.0, // You might want to make these configurable too
      left: 10.0,
      right: 60.0,
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
                  'Area: ${currentlyClickedArea!.name}\nUsers in area: 12345', // Placeholder for user count
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(height: 1.3),
                ),
              ),
              const SizedBox(width: 8), // Add some space between text and buttons
              TextButton(
                onPressed: () {
                  onChatNavigation(currentlyClickedArea!);
                },
                child: const Text('Chat'),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                tooltip: 'Close',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
