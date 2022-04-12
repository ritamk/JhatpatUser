import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jhatpat/models/map_models.dart';
import 'package:jhatpat/services/database/database.dart';

class GoogleDirectionAPI {
  static const String _baseUrl =
      "https://maps.googleapis.com/maps/api/directions/json?";

  final Dio _dio = Dio();

  Future<Directions?> getDirections(
      {required LatLng pickup, required LatLng destination}) async {
    try {
      final response = await _dio.get(_baseUrl, queryParameters: {
        'origin': '${pickup.latitude},${pickup.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': API_KEY,
      });
      print(response.data);
      return Directions.fromMap(response.data);
    } catch (e) {
      print("getDirections: ${e.toString()}");
      Future.error(e.toString());
    }
  }
}
