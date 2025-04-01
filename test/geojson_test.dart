import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map_geojson2/flutter_map_geojson2.dart';
import 'app.dart';

void main() {
  testWidgets('Empty layer works', (tester) async {
    await tester.pumpWidget(JsonTestApp(
      layer: GeoJsonLayer(
        data: MemoryGeoJson({}),
      ),
    ));
    expect(find.byType(GeoJsonLayer), findsOneWidget);
    expect(find.byType(MarkerLayer), findsNothing);
    expect(find.byType(PolylineLayer), findsNothing);
    expect(find.byType(PolygonLayer), findsNothing);
  });

  testWidgets('Creates a linestring from a single feature', (tester) async {
    await tester.pumpWidget(JsonTestApp(
      layer: GeoJsonLayer.memory({
          'type': 'Feature',
          'geometry': {
            'type': 'LineString',
            'coordinates': [
              [24.7, 59.4],
              [24.8, 59.401]
            ],
          },
          'properties': {
            'stroke': '#22e',
            'stroke-width': 11,
          },
        }),
      ),
    );
    await tester.pumpAndSettle(Duration(milliseconds: 100));
    expect(find.byType(GeoJsonLayer), findsOneWidget);
    expect(find.byType(MarkerLayer), findsNothing);
    expect(find.byType(PolylineLayer), findsOneWidget);
    expect(find.byType(PolygonLayer), findsNothing);

    final polyline = tester.firstWidget<PolylineLayer>(find.byType(PolylineLayer));
    expect(polyline.polylines.length, equals(1));
    expect(polyline.polylines.first.strokeWidth, equals(11.0));
    expect(polyline.polylines.first.color, equals(Color(0xff2222ee)));
  });

  /*testWidgets('Downloads data from the network', (tester) async {
    await tester.pumpWidget(JsonTestApp(
      layer: GeoJsonLayer(
        data: NetworkGeoJson(
            'https://raw.githubusercontent.com/mapbox/simplestyle-spec/refs/heads/master/1.1.0/example.geojson'),
      ),
    ));
    expect(find.byType(GeoJsonLayer), findsOneWidget);
    await tester.pumpAndSettle(Duration(seconds: 1));
    expect(find.byType(MarkerLayer), findsOneWidget);
    expect(find.byType(PolylineLayer), findsOneWidget);
  });*/
}
