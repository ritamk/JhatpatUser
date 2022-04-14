import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  final LatLngBounds latLngBounds;
  final List<PointLatLng> polylinePoints;
  // final String totalDist;
  // final String totalDuration;

  Directions({
    required this.latLngBounds,
    required this.polylinePoints,
    // required this.totalDist,
    // required this.totalDuration,
  });

  static fromMap(Map<String, dynamic> map) {
    if ((map['routes'] as List).isEmpty) return null;

    final data = Map<String, dynamic>.from(map['routes'][0]);
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);

    String dist = "";
    String durn = "";
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      dist = leg['distance']['text'];
      durn = leg['duration']['text'];
    }

    return Directions(
      latLngBounds: bounds,
      polylinePoints:
          PolylinePoints().decodePolyline(data['overview_polyline']['points']),
    );
    // totalDist: dist,
    // totalDuration: durn);
  }
}
