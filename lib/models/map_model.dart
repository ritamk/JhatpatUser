import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapModel {
  final LatLngBounds bounds;
  final List<PointLatLng> polyLinePts;
  final String totalDist;
  final String totalDur;

  MapModel({
    required this.bounds,
    required this.polyLinePts,
    required this.totalDist,
    required this.totalDur,
  });

  static fromMap(Map<String, dynamic> map) {
    if (map["routes"].isEmpty) {
      return null;
    }

    final Map data = Map.from(map["routes"][0]);

    final northeast = data["bounds"]["northeast"];
    final southwest = data["bounds"]["southwest"];
    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);

    String dist = "";
    String durn = "";
    if (data["legs"].isNotEmpty) {
      final leg = data["legs"][0];
      dist = leg["distance"]["text"];
      durn = leg["duration"]["text"];
    }

    return MapModel(
      bounds: bounds,
      polyLinePts:
          PolylinePoints().decodePolyline(data["overview_polyline"]["points"]),
      totalDist: dist,
      totalDur: durn,
    );
  }
}
