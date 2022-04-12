import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jhatpat/shared/text_field_deco.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';
import 'package:jhatpat/views/home/home_drawer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _myLocLoading = false;

  late GoogleMapController _controller;
  static const LatLng initCoord = LatLng(22.580597, 88.4223668);
  Position? coord;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final String _destMarkerId = "DestinationMarker";
  final String _myMarkerId = "PickupMarker";

  static const CameraPosition _initCamPos = CameraPosition(
    target: initCoord,
    zoom: 14,
  );

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
        zoom: 19.0,
      )));
      addMarker(false, LatLng(coord!.latitude, coord!.longitude));
    } else {
      commonSnackbar("Cannot access current location", context);
    }
    setState(() => _myLocLoading = false);
  }

  void addMarker(bool destination, LatLng coordinate) {
    final MarkerId markerId =
        MarkerId(destination ? _destMarkerId : _myMarkerId);

    final Marker marker = Marker(
      markerId: markerId,
      position: coordinate,
      icon: BitmapDescriptor.defaultMarkerWithHue(
          destination ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed),
    );

    setState(() => markers[markerId] = marker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   elevation: 2.0,
        //   title: const Text("Home"),
        //   // title: TextField(
        //   //   decoration: authTextInputDecoration(
        //   //       "Search for a place", Icons.search, null),

        //   // ),
        //   backgroundColor: Colors.white,
        // ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                title: Text("Home"),
              ),
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initCamPos,
                onMapCreated: (GoogleMapController controller) =>
                    _controller = controller,
                zoomControlsEnabled: false,
                compassEnabled: true,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                onLongPress: (LatLng latLng) {
                  addMarker(true, latLng);
                },
                markers: Set<Marker>.of(markers.values),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: _goToCurrLocation,
          child: !_myLocLoading
              ? const Icon(Icons.my_location_rounded)
              : const Loading(white: true),
          tooltip: "Current Location",
        ),
        drawer: const HomeDrawer());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

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

  // late BitmapDescriptor pickupIcon;
  // late BitmapDescriptor dropoffIcon;

  // @override
  // void initState() {
  //   super.initState();
  //   BitmapDescriptor.fromAssetImage(
  //           const ImageConfiguration(size: Size(20.0, 20.0)),
  //           "assets/images/MapIconPickup.png")
  //       .then((value) => pickupIcon = value);
  //   BitmapDescriptor.fromAssetImage(
  //           const ImageConfiguration(size: Size(20.0, 20.0)),
  //           "assets/images/MapIconDropoff.png")
  //       .then((value) => dropoffIcon = value);
  // }