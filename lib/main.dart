import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:connect_flutter/widgets/map_view.dart';
import 'package:connect_flutter/widgets/settings/settings_overlay.dart';

void main() async {
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect All',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _currentZoom = 12.0;
  final Logger _logger = Logger();

  bool isLoggedIn = false; // Set to true if user is logged in
  String userStatus = "Guest";

  void _updateCurrentZoom(double? newZoom) {
    if (newZoom == null) return;
    if (_currentZoom != newZoom) {
      setState(() {
        _currentZoom = newZoom;
      });
    }
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => SettingsOverlay(
        isLoggedIn: isLoggedIn,
        onLoginStateChanged: (loggedIn) {
          setState(() {
            isLoggedIn = loggedIn;
            userStatus = loggedIn ? "Logged in" : "Guest";
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Connect All - $userStatus - ${_currentZoom.toStringAsFixed(2)}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: MapView(
        currentZoom: _currentZoom,
        onZoomChanged: _updateCurrentZoom,
        logger: _logger,
      ),
    );
  }
}