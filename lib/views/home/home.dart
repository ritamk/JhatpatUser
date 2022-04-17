import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gmwp;
import 'package:jhatpat/models/map_model.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';
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
  bool _choosingDest = false;
  bool _showDist = false;

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
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  List<LatLng> polylineCoordinates = <LatLng>[];
  PolylinePoints polylinePoints = PolylinePoints();
  String _destString = "Enter destination point";
  String _originString = "Enter pick-up point";
  MapModel? _model;
  String _dist = "XX km";
  String _durn = "XX hours XX mins";

  @override
  void initState() {
    super.initState();
    setInitCameraPos();
  }

  @override
  Widget build(BuildContext context) {
    if (!_mapLoading) {
      return Scaffold(
        appBar: _showTextFields
            ? AppBar(
                leading: Builder(builder: (context) {
                  return IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                    ),
                  );
                }),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // Pick up
                    InkWell(
                      onTap: () => _autcompletePlaces(false),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  _originString,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Destination
                    InkWell(
                      onTap: () => _autcompletePlaces(true),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  _destString,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                toolbarHeight: 120.0,
                elevation: 4.0,
                backgroundColor: Colors.black,
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 18.0),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        const SizedBox(width: 15.0),
                        Positioned(
                          top: 10.0,
                          child: IconButton(
                            onPressed: () =>
                                setState(() => _choosingDest = false),
                            icon: Icon(
                              Icons.location_on,
                              color: !_choosingDest
                                  ? Colors.red.shade700
                                  : Colors.red.shade200,
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(0.0),
                            tooltip: "Mark pick-up on map",
                          ),
                        ),
                        Positioned(
                          bottom: 10.0,
                          child: IconButton(
                            onPressed: () =>
                                setState(() => _choosingDest = true),
                            icon: Icon(
                              Icons.location_on,
                              color: _choosingDest
                                  ? Colors.blue.shade700
                                  : Colors.blue.shade200,
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(0.0),
                            tooltip: "Mark destination on map",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const PreferredSize(
                child: SizedBox(), preferredSize: Size(0.0, 0.0)),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initCamPos,
              onMapCreated: (GoogleMapController controller) =>
                  _controller = controller,
              onLongPress: (LatLng latLng) {
                addMarker(_choosingDest, latLng);
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
              compassEnabled: false,
              polylines: <Polyline>{
                if (_model != null)
                  Polyline(
                    points: _model!.polyLinePts
                        .map((PointLatLng e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                    polylineId: PolylineId(_polyLineRouteId),
                    color: Colors.black,
                    width: 5,
                    startCap: Cap.roundCap,
                    endCap: Cap.roundCap,
                  ),
              },
              onCameraMove: (pos) => _cameraPosn = pos,
            ),
            if (_showDist)
              Positioned(
                bottom: 25.0,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: Text(
                      "$_dist, \t$_durn",
                      style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  elevation: 4.0,
                ),
              ),
          ],
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
              onPressed: getDirections,
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

  /// Fetch route info from Google Directions API
  void getDirections() async {
    if (_pickupLatLng != null && _dropoffLatLng != null) {
      setState(() => _routeLoading = true);
      try {
        final directions = await GetDirections()
            .getDirections(_pickupLatLng!, _dropoffLatLng!);
        setState(() => _model = directions);
        if (_model != null) {
          CameraUpdate.newLatLngBounds(_model!.bounds, 4.0);
          _dist = _model!.totalDist;
          _durn = _model!.totalDur;
          _showDist = true;
        } else {
          commonSnackbar("Something went wrong, couldn't load route", context);
        }
      } catch (e) {
        commonSnackbar("Something went wrong, couldn't load route", context);
      }
    } else {
      commonSnackbar(
          "Either/both of pick-up or/and destination markers have not been set.",
          context);
    }
    setState(() => _routeLoading = false);
  }

  /// Initialise the position of the camera at the start of the application.
  /// If a previously stored instance of camera position is available on the
  /// device then it is used.
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

  /// Uses the Google Places API to generate search results for places.
  _autcompletePlaces(bool dest) async {
    var place = await PlacesAutocomplete.show(
      context: context,
      apiKey: API_KEY,
      mode: Mode.overlay,
      types: [],
      strictbounds: false,
      onError: (gmwp.PlacesAutocompleteResponse e) => print(e.errorMessage),
    );

    if (place != null) {
      setState(() => dest
          ? _destString = place.description.toString()
          : _originString = place.description.toString());

      final plist = gmwp.GoogleMapsPlaces(
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
          CameraPosition(target: newlatlang, zoom: _initZoom),
        ),
      );

      if (dest) {
        _dropoffLatLng = LatLng(lat, lang);
        addMarker(true, _dropoffLatLng!);
      } else {
        _pickupLatLng = LatLng(lat, lang);
        addMarker(false, _pickupLatLng!);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
