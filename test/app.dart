import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson2/flutter_map_geojson2.dart';
import 'package:latlong2/latlong.dart';

class JsonTestApp extends StatelessWidget {
  final GeoJsonLayer layer;
  final LatLng? center;

  const JsonTestApp({super.key, required this.layer, this.center});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FlutterMap(
          options: MapOptions(
            initialCenter: center ?? LatLng(59.4, 24.7),
            initialZoom: 12,
          ),
          children: [layer],
        ),
      ),
    );
  }
}
