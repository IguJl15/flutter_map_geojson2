import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson2/flutter_map_geojson2.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_color_names/material_color_names.dart';

/// Default values for default object builders. Functions [defaultOnPoint],
/// [defaultOnPolyline], and [defaultOnPolygon] use values from this
/// object for properties missing in GeoJSON objects.
///
/// There are two singletons that can be used without instantiating
/// this class: [initial] (used by default) and [leaflet].
class GeoJsonStyleDefaults {
  final Color markerColor;
  final String markerSize;
  final Color strokeColor;
  final double strokeOpacity;
  final double strokeWidth;
  final Color fillColor;
  final double fillOpacity;

  /// Defaults as defined in the [simplestyle-spec](https://github.com/mapbox/simplestyle-spec/blob/master/1.1.0/README.md).
  /// Colors are shades of gray, strokes are 2 pixels wide,
  /// and the default fill opacity is 0.6.
  static const initial = GeoJsonStyleDefaults();

  /// Defaults as defined in the [Leaflet library](https://leafletjs.com/reference.html#path).
  /// Colors are blue, strokes are 3 pixels wide, and
  /// the default fill opacity is very faint, 0.2.
  static const leaflet = GeoJsonStyleDefaults(
    strokeColor: Color(0xff3388ff),
    strokeOpacity: 1.0,
    strokeWidth: 3,
    fillColor: Color(0xff3388ff),
    fillOpacity: 0.2,
  );

  const GeoJsonStyleDefaults({
    this.markerColor = const Color(0xff7e7e7e),
    this.markerSize = 'medium',
    this.strokeColor = const Color(0xff555555),
    this.strokeOpacity = 1.0,
    this.strokeWidth = 2.0,
    this.fillColor = const Color(0xff555555),
    this.fillOpacity = 0.6,
  });
}

const _kMarkerSizes = <String, double>{
  'small': 20.0,
  'medium': 36.0,
  'large': 48.0,
};

/// Default implementation for [GeoJsonLayer.onPoint]. Parses object properties
/// to determine marker style. Those properties are supported:
///
/// * `marker-color`: marker color, as a material color name or a hexadecimal value.
/// * `marker-size`: a choice from "small", "medium", and "large".
Marker defaultOnPoint(LatLng point, Map<String, dynamic> props,
    {GeoJsonStyleDefaults? defaults}) {
  defaults ??= GeoJsonStyleDefaults.initial;

  Color? color = props.containsKey('marker-color')
      ? colorFromString(props['marker-color'])
      : null;
  color ??= defaults.markerColor;

  final double size =
      _kMarkerSizes[props['marker-size'] ?? defaults.markerSize] ??
          _kMarkerSizes[defaults.markerSize] ??
          _kMarkerSizes['medium']!;

  return Marker(
    point: point,
    width: size,
    height: size,
    alignment: Alignment.bottomCenter,
    child: Icon(
      Icons.location_pin,
      color: color,
      size: size,
    ),
  );
}

/// Default implementation for [GeoJsonLayer.onPolyline]. Parses object properties
/// to determine polyline style. Those properties are supported:
///
/// * `stroke`: line color, as a material color name or a hexadecimal value.
/// * `stroke-opacity`: opacity, a floating-point number between 0.0 and 1.0.
/// * `stroke-width`: line width in pixels.
Polyline defaultOnPolyline(List<LatLng> points, Map<String, dynamic> props,
    {GeoJsonStyleDefaults? defaults}) {
  defaults ??= GeoJsonStyleDefaults.initial;

  Color? stroke =
      props.containsKey('stroke') ? colorFromString(props['stroke']) : null;
  stroke ??= defaults.strokeColor;

  dynamic opacity = props['stroke-opacity'];
  if (opacity is String) opacity = double.tryParse(opacity);
  if (opacity is num && opacity >= 0.0 && opacity <= 1.0) {
    stroke = stroke.withValues(alpha: opacity.toDouble());
  } else if (stroke.a > 0.99) {
    stroke = stroke.withValues(alpha: defaults.strokeOpacity);
  }

  dynamic width = props['stroke-width'];
  if (width is String) width = double.tryParse(width);

  return Polyline(
    points: points,
    color: stroke,
    strokeWidth: width is num ? width.toDouble() : defaults.strokeWidth,
  );
}

/// Default implementation for [GeoJsonLayer.onPolygon]. Parses object properties
/// to determine polygon style. Those properties are supported:
///
/// * `fill`: fill color, as a material color name or a hexadecimal value.
/// * `fill-opacity`: opacity, a floating-point number between 0.0 and 1.0.
/// * Stroke options from [defaultOnPolyline] are also included for the
///   polygon border.
Polygon defaultOnPolygon(
    List<LatLng> points, List<List<LatLng>>? holes, Map<String, dynamic> props,
    {GeoJsonStyleDefaults? defaults}) {
  defaults ??= GeoJsonStyleDefaults.initial;

  Color? fill =
      props.containsKey('fill') ? colorFromString(props['fill']) : null;
  fill ??= defaults.fillColor;

  dynamic opacity = props['fill-opacity'];
  if (opacity is String) opacity = double.tryParse(opacity);
  if (opacity is num && opacity >= 0.0 && opacity <= 1.0) {
    fill = opacity == 0.0 ? null : fill.withValues(alpha: opacity.toDouble());
  } else if (fill.a > 0.99) {
    fill = fill.withValues(alpha: defaults.fillOpacity);
  }

  Color? stroke =
      props.containsKey('stroke') ? colorFromString(props['stroke']) : null;
  stroke ??= defaults.strokeColor;

  dynamic sOpacity = props['stroke-opacity'];
  if (sOpacity is String) sOpacity = double.tryParse(sOpacity);
  if (sOpacity is num && sOpacity >= 0.0 && sOpacity <= 1.0) {
    stroke = stroke.withValues(alpha: sOpacity.toDouble());
  } else if (stroke.a > 0.99) {
    stroke = stroke.withValues(alpha: defaults.strokeOpacity);
  }

  dynamic width = props['stroke-width'];
  if (width is String) width = double.tryParse(width);

  return Polygon(
    points: points,
    holePointsList: holes,
    color: fill,
    borderColor: stroke,
    borderStrokeWidth: width is num ? width.toDouble() : defaults.strokeWidth,
  );
}
