import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:logger/logger.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:connect_flutter/widgets/map_view.dart';

void main() async {
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Map Demo'),
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
  double _currentZoom = 12.0;
  final Logger _logger = Logger();

  void _updateCurrentZoom(double? newZoom) {
    if (newZoom == null) return;
    if (_currentZoom != newZoom) {
      setState(() {
        _currentZoom = newZoom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('${widget.title} - Zoom: ${_currentZoom.toStringAsFixed(2)}'),
      ),
      body: MapView(
        currentZoom: _currentZoom,
        onZoomChanged: _updateCurrentZoom,
        logger: _logger,
      ),
    );
  }
}