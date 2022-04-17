import 'dart:convert';

// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:jhatpat/models/map_model.dart';
import 'package:jhatpat/services/database/database.dart';

Future<Position?> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Please enable location services.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Please allow location permissions.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Cannot request permissions, location permissions are permanently denied.');
  }

  try {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  } catch (e) {
    return Geolocator.getLastKnownPosition();
  }
}

class MapNotifier extends ChangeNotifier {}

class GetDirections {
  static const String _baseUrl =
      "https://maps.googleapis.com/maps/api/directions/json?";

  // final Dio _dio = Dio();

  Future<MapModel> getDirections(LatLng originLatLng, LatLng destLatLng) async {
    final Map<String, dynamic> queryParams = {
      "origin": "${originLatLng.latitude},${originLatLng.longitude}",
      "destination": "${destLatLng.latitude},${destLatLng.longitude}",
      "key": API_KEY,
    };
    try {
      final Uri uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      final Response response = await get(uri);
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);

      if (decodedResponse["routes"].isEmpty) {
        throw "Something went wrong, please try again";
      }

      final Map<String, dynamic> routes =
          Map<String, dynamic>.from(decodedResponse["routes"][0]);
      final LatLng northeast = LatLng(routes["bounds"]["northeast"]["lat"],
          routes["bounds"]["northeast"]["lng"]);
      final LatLng southwest = LatLng(routes["bounds"]["southwest"]["lat"],
          routes["bounds"]["southwest"]["lng"]);
      final LatLngBounds bounds =
          LatLngBounds(southwest: southwest, northeast: northeast);
      String dist = "";
      String durn = "";
      if (routes["legs"].isNotEmpty) {
        final Map<String, dynamic> leg = routes["legs"][0];
        dist = leg["distance"]["text"];
        durn = leg["duration"]["text"];
      }

      return MapModel(
          bounds: bounds,
          polyLinePts: PolylinePoints()
              .decodePolyline(routes["overview_polyline"]["points"]),
          totalDist: dist,
          totalDur: durn);
    } catch (e) {
      throw e.toString();
    }
  }
}
