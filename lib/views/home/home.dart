import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_directions_api/google_directions_api.dart' as gdir;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jhatpat/models/map_models.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';
import 'package:jhatpat/shared/text_field_deco.dart';
import 'package:jhatpat/views/home/g_dirn_api.dart';
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
  bool _showTextFields = true;

  late GoogleMapController _controller;
  late LatLng _initCoord;
  Position? coord;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final String _polyLineRouteId = "polyRoute";
  final String _destMarkerId = "DestinationMarker";
  LatLng? _pickupLatLng;
  final String _myMarkerId = "PickupMarker";
  LatLng? _dropoffLatLng;
  final double _initZoom = 14.0;
  final double _selectedZoom = 19.0;
  late CameraPosition _initCamPos;
  late CameraPosition _cameraPosn = _initCamPos;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final gdir.DirectionsService directionsService = gdir.DirectionsService();
  Directions? _routeInfo;

  @override
  void initState() {
    super.initState();
    setInitCameraPos();
    setState(() {});
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
      zoom: _initZoom,
    );
    setState(() => _mapLoading = false);
  }

  /// Moves camera to current location and marks it
  /// as the pickup point.
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
        zoom: _selectedZoom,
      )));
      addMarker(false, LatLng(coord!.latitude, coord!.longitude));
    } else {
      commonSnackbar("Cannot access current location", context);
    }
    setState(() => _myLocLoading = false);
  }

  /// Makes the camera bearing 0.0 hence turning the map
  /// to North side facing upwards.
  void _turnCompassNorth() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: _cameraPosn.target,
      bearing: 0.0,
      zoom: _cameraPosn.zoom,
      tilt: _cameraPosn.tilt,
    )));
  }

  /// Adds a blue marker for pickup location and
  /// a blue marker for drop-off location.
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

  /// Tries to retrieve route information between
  /// two coordinates from Google Directions API.
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
    if (!_mapLoading) {
      return Scaffold(
        appBar: _showTextFields
            ? AppBar(
                toolbarHeight: 120.0,
                elevation: 3.0,
                title: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                  decoration: searchTextInputDecoration(
                                      "Enter origin",
                                      Icons.location_on_rounded,
                                      null)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5.0, width: 0.0),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                  decoration: searchTextInputDecoration(
                                      "Enter destination",
                                      Icons.location_on_rounded,
                                      null)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                backgroundColor: Colors.white,
              )
            : null,
        body: GoogleMap(
          mapType: MapType.terrain,
          initialCameraPosition: _initCamPos,
          onMapCreated: (GoogleMapController controller) =>
              _controller = controller,
          onLongPress: (LatLng latLng) {
            addMarker(true, latLng);
          },
          onTap: (LatLng latLng) {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() => _showTextFields
                ? _showTextFields = false
                : _showTextFields = true);
          },
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
          onCameraMove: (pos) => _cameraPosn = pos,
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
      );
    } else {
      return const Scaffold(
        body: Loading(white: false, rad: 14.0),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
