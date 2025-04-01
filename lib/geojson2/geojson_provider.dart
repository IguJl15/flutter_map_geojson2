import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io' show File, HttpClient, HttpStatus, IOException;

import 'package:flutter/services.dart';

class NotAGeoJson implements Exception {
  const NotAGeoJson();
}

class GeoJsonLoadException implements IOException {
  final String message;

  const GeoJsonLoadException(this.message);

  @override
  String toString() => 'GeoJsonLoadException("$message")';
}

void _validateGeoJson(dynamic data) {
  if (data is! Map<String, dynamic>) {
    throw GeoJsonLoadException("Contents are not a GeoJSON.");
  }
  const kValidTypes = {'FeatureCollection', 'Feature'};
  if (!kValidTypes.contains(data['type'])) {
    throw GeoJsonLoadException(
        "Root object type is not valid for a GeoJSON: ${data['type']}");
  }
}

/// Identifies a GeoJSON file without having the actual data.
abstract class GeoJsonProvider {
  const GeoJsonProvider();
  FutureOr<Map<String, dynamic>> loadData();
}

class MemoryGeoJson extends GeoJsonProvider {
  final Map<String, dynamic> data;

  const MemoryGeoJson(this.data);

  @override
  FutureOr<Map<String, dynamic>> loadData() {
    _validateGeoJson(data);
    return data;
  }
}

class FileGeoJson extends GeoJsonProvider {
  final File file;

  const FileGeoJson(this.file);

  @override
  FutureOr<Map<String, dynamic>> loadData() async {
    if (!await file.exists()) {
      throw GeoJsonLoadException("File ${file.path} does not exist");
    }

    dynamic data;
    try {
      final String contents = await file.readAsString();
      data = json.decode(contents);
    } on Exception catch (e) {
      throw GeoJsonLoadException("Error loading or parsing GeoJSON: $e");
    }
    _validateGeoJson(data);
    return data;
  }
}

class AssetGeoJson extends GeoJsonProvider {
  final String asset;
  final AssetBundle? bundle;

  const AssetGeoJson(this.asset, {this.bundle});

  @override
  FutureOr<Map<String, dynamic>> loadData() async {
    final bundle = this.bundle ?? rootBundle;
    dynamic data;
    try {
      final String content = await bundle.loadString(asset, cache: false);
      data = json.decode(content);
    } on Exception catch (e) {
      throw GeoJsonLoadException(
          "Error loading or parsing GeoJSON from bundle: $e");
    }
    _validateGeoJson(data);
    return data;
  }
}

class NetworkGeoJson extends GeoJsonProvider {
  final String url;
  final Map<String, String> headers;

  const NetworkGeoJson(this.url, {this.headers = const {}});

  static final _httpClient = HttpClient();

  @override
  FutureOr<Map<String, dynamic>> loadData() async {
    String content;
    try {
      final uri = Uri.base.resolve(url);
      final request = await _httpClient.getUrl(uri);
      headers.forEach((k, v) {
        request.headers.add(k, v);
      });
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        await response.drain([]);
        throw GeoJsonLoadException(
            "Error requesting GeoJSON from $url: HTTP ${response.statusCode}");
      }
      content = await response.transform(utf8.decoder).join();
    } on Exception catch (e) {
      if (e is GeoJsonLoadException) rethrow;
      throw GeoJsonLoadException("Error downloading GeoJSON from $url: $e");
    }

    dynamic data;
    try {
      data = json.decode(content);
    } on Exception catch (e) {
      throw GeoJsonLoadException("Error parsing GeoJSON: $e");
    }

    _validateGeoJson(data);
    return data;
  }
}
