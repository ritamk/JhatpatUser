import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_directions_api/google_directions_api.dart' as gdir;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gweb;
import 'package:jhatpat/models/map_models.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';
import 'package:jhatpat/views/home/directions_repo.dart';
import 'package:jhatpat/views/home/home_drawer.dart';
import 'package:jhatpat/views/home/location_services.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _routeLoading = false;
  bool _mapLoading = true;
  bool _myLocLoading = false;
  late GoogleMapController _controller;
  late LatLng _initCoord;
  Position? coord;
  late CameraPosition currentPosn;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final String _polyLineRouteId = "polyRoute";
  final String _destMarkerId = "DestinationMarker";
  LatLng? _pickupLatLng;
  final String _myMarkerId = "PickupMarker";
  LatLng? _dropoffLatLng;
  String _searchString = "";
  late CameraPosition _initCamPos;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final gdir.DirectionsService directionsService = gdir.DirectionsService();
  Directions? _routeInfo;

  @override
  void initState() {
    super.initState();
    setInitCameraPos();
  }

  void setInitCameraPos() {
    List<double?> initSavedCoord = UserSharedPreferences.getMapGeoLoc();
    _initCoord = initSavedCoord.isEmpty
        ? const LatLng(22.580597, 88.4223668)
        : LatLng(initSavedCoord[0]!, initSavedCoord[1]!);
    _initCamPos = CameraPosition(
      target: _initCoord,
      bearing: 0.0,
      tilt: 0.0,
      zoom: 14,
    );
    setState(() => _mapLoading = false);
  }

  void _goToCurrLocation() async {
    setState(() => _myLocLoading = true);
    try {
      coord = await determinePosition();
    } catch (e) {
      commonSnackbar(e.toString(), context);
    }
    if (coord != null) {
      _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(coord!.latitude, coord!.longitude),
        bearing: 0.0,
        tilt: 0.0,
        zoom: 19.0,
      )));
      addMarker(false, LatLng(coord!.latitude, coord!.longitude));
    } else {
      commonSnackbar("Cannot access current location", context);
    }
    setState(() => _myLocLoading = false);
  }

  void _turnCompassNorth() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: currentPosn.target, bearing: 0.0, zoom: currentPosn.zoom)));
  }

  void addMarker(bool destination, LatLng coordinate) async {
    final MarkerId markerId =
        MarkerId(destination ? _destMarkerId : _myMarkerId);

    final Marker marker = Marker(
      markerId: markerId,
      position: coordinate,
      icon: BitmapDescriptor.defaultMarkerWithHue(
          destination ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed),
    );

    try {
      await UserSharedPreferences.setMapGeoLoc(
          coordinate.latitude, coordinate.longitude);
    } catch (e) {
      null;
    }

    setState(() {
      markers[markerId] = marker;
      if (destination) {
        _dropoffLatLng = coordinate;
      } else {
        _pickupLatLng = coordinate;
      }
    });
  }

  void addPolyLine() {
    PolylineId id = PolylineId(_polyLineRouteId);
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  void getPolyline() async {
    if (_dropoffLatLng != null && _pickupLatLng != null) {
      PolylineResult? result;
      try {
        result = await polylinePoints.getRouteBetweenCoordinates(
            API_KEY,
            PointLatLng(_pickupLatLng!.latitude, _pickupLatLng!.longitude),
            PointLatLng(_dropoffLatLng!.latitude, _dropoffLatLng!.longitude),
            travelMode: TravelMode.driving,
            wayPoints: [
              PolylineWayPoint(location: "Route")
            ]).whenComplete(() => setState(() => _routeLoading = false));
        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }
        addPolyLine();
      } catch (e) {
        print(e.toString());
      }
    } else {
      null;
    }
  }

  getDir() async {
    if (_dropoffLatLng != null && _pickupLatLng != null) {
      setState(() => _routeLoading = true);
      try {
        _routeInfo = await GoogleDirectionAPI().getDirections(
            pickup: _pickupLatLng!, destination: _dropoffLatLng!);
      } catch (e) {
        commonSnackbar(e.toString(), context);
      }
    } else {
      commonSnackbar(
          "Either/both of pick-up or/and destination markers not set yet",
          context);
    }
    setState(() => _routeLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return !_mapLoading
        ? Scaffold(
            appBar: AppBar(
              elevation: 3.0,
              title: InkWell(
                onTap: () async {
                  var place = await PlacesAutocomplete.show(
                    context: context,
                    apiKey: API_KEY,
                    mode: Mode.fullscreen,
                    types: [],
                    strictbounds: false,
                    onError: (gweb.PlacesAutocompleteResponse e) =>
                        print(e.errorMessage),
                  );

                  if (place != null) {
                    setState(() {
                      _searchString = place.description.toString();
                    });

                    final plist = gweb.GoogleMapsPlaces(
                      apiKey: API_KEY,
                      apiHeaders: await const GoogleApiHeaders().getHeaders(),
                    );

                    String placeId = place.placeId ?? "0";
                    final detail = await plist.getDetailsByPlaceId(placeId);
                    final geometry = detail.result.geometry;
                    final lat = geometry?.location.lat ?? _initCoord.latitude;
                    final lang = geometry?.location.lng ?? _initCoord.longitude;
                    var newlatlang = LatLng(lat, lang);

                    _controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: newlatlang, zoom: 19.0),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: const <Widget>[
                          Text(
                            "Search",
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 0.0, width: 20.0),
                          Icon(Icons.search, color: Colors.black54)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              backgroundColor: Colors.white,
            ),
            body: GoogleMap(
              mapType: MapType.terrain,
              initialCameraPosition: _initCamPos,
              onMapCreated: (GoogleMapController controller) =>
                  _controller = controller,
              onLongPress: (LatLng latLng) {
                addMarker(true, latLng);
              },
              onTap: (LatLng latLng) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              onCameraMove: (CameraPosition cameraPosn) =>
                  currentPosn = cameraPosn,
              markers: Set<Marker>.of(markers.values),
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              compassEnabled: true,
              polylines: {
                if (_routeInfo != null)
                  Polyline(
                    polylineId: PolylineId(_polyLineRouteId),
                    color: Colors.red,
                    width: 5,
                    points: _routeInfo!.polylinePoints
                        .map(
                          (e) => LatLng(e.latitude, e.longitude),
                        )
                        .toList(),
                  ),
              },
            ),
            floatingActionButton: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: "btn3",
                  backgroundColor: Colors.black,
                  // onPressed: getPolyline,
                  onPressed: getDir,
                  child: !_routeLoading
                      ? const Icon(Icons.navigation_rounded)
                      : const Loading(white: true),
                  tooltip: "Find Route",
                ),
                const SizedBox(height: 10.0, width: 0.0),
                FloatingActionButton(
                  heroTag: "btn2",
                  backgroundColor: Colors.black,
                  onPressed: _turnCompassNorth,
                  child: const Icon(Icons.north),
                  tooltip: "North",
                ),
                const SizedBox(height: 10.0, width: 0.0),
                FloatingActionButton(
                  heroTag: "btn1",
                  backgroundColor: Colors.black,
                  onPressed: _goToCurrLocation,
                  child: !_myLocLoading
                      ? const Icon(Icons.my_location_rounded)
                      : const Loading(white: true),
                  tooltip: "Current Location",
                ),
              ],
            ),
            drawer: const HomeDrawer(),
          )
        : const Scaffold(
            body: Loading(white: false, rad: 14.0),
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
