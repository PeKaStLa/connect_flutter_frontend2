import 'package:flutter/material.dart';
import 'package:connect_flutter/services/pocketbase.dart';
import 'package:connect_flutter/utils/map_utils.dart';

class LogoutConfirmPage extends StatelessWidget {
  final VoidCallback onConfirm;
  const LogoutConfirmPage({required this.onConfirm, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        key: const ValueKey('logoutConfirmPage'),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                logoutUser();
                // Guarded snackbar after async gap
                await Future.delayed(const Duration(milliseconds: 100));
                if (context.mounted) {
                  snackbar(context, "Logout successful!");
                }
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Yes, I want to logout'),
            ),
          ],
        ),
      ),
    );
  }
}