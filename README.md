# GeoJSON layer for Flutter Map

This package adds a `GeoJsonLayer` class, which can be added to a list
of layers in `flutter_map` to display data from a GeoJSON source. There
are convenience constructors for using GeoJSON data from an asset
or to download it from a website. The layer supports
[simplespec](https://github.com/mapbox/simplestyle-spec/blob/master/1.1.0/README.md)
to style features according to their properties, and allows overriding
the defaults and filtering the features.

## Getting started

The same as for all other packages: copy the package name and version
into your `pubspec.yaml`, and in your class, import the package:

    import 'package:flutter_map_geojson2/flutter_map_geojson2.dart';

## Usage

Pretty straightforward if you have used `flutter_map` before. Use the
layer like this:

```dart
@override
Widget build(BuildContext context) {
  return FlutterMap(
    options: MapOptions(...),
    layers: [
      GeoJsonLayer.memory({
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
    ],
  );
}
```

Alternatively you can package a GeoJSON file in the assets (don't forget to
list them in `pubspec.yaml`) and add to your map like this:

```dart
layers: [
  GeoJsonLayer.asset('data/overlay.geojson'),
],
```

To override marker and other object creation functions, see the corresponding
layer class arguments. You can have lines and polygons tappable by supplying
a `hitNotifier` object. For markers, you obviously can override the entire
thing.

## Additional information

Note that there is no explicit error handling in the widget. Meaning, if you get
broken data, it just won't be displayed without any notification. Broken
GeoJSON features get silently skipped. If you have any ideas on how to do this properly,
I'd love to hear them.

Thanks to [flutter_map](https://pub.dev/packages/flutter_map) authors for the
ultimate mapping solution for Flutter, and to Joze, the
[flutter_map_geojson](https://pub.dev/packages/flutter_map_geojson) author
for the inspiration. This package differs from his in using cleaner API
and recent Flutter Map features.