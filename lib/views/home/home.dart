import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jhatpat/models/user.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/providers.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';
import 'package:jhatpat/views/home/home_drawer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool loading = true;
  bool userProfileComplete = false;
  bool errorLoadingProfile = false;
  UserProfileData? userProfileData;

  late GoogleMapController _controller;
  Position? coord;

  @override
  void initState() {
    super.initState();
    checkUserData().whenComplete(
      () => setState(() => loading = false),
    );
  }

  Future checkUserData() async {
    try {
      userProfileData =
          await DatabaseService(token: UserSharedPreferences.getUserToken())
              .getProfileDetails();

      if (userProfileData.runtimeType == UserProfileData) {
        if (userProfileData!.name!.isEmpty) {
        } else {
          setState(() => userProfileComplete = true);
        }
      } else {
        commonSnackbar("Something went wrong, please try again", context);
      }
    } catch (e) {
      commonSnackbar(e.toString(), context);
      setState(() => errorLoadingProfile = true);
    }
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(22.580597, 88.4223668),
    zoom: 14.4746,
  );

  void _goToCurrLocation() async {
    try {
      coord = await determinePosition();
    } catch (e) {
      commonSnackbar(e.toString(), context);
    }
    coord != null
        ? _controller
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(coord!.latitude, coord!.longitude),
            zoom: 19.0,
          )))
        : commonSnackbar("Cannot access current location", context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      // body: Center(
      //   child: !loading
      //       ? Text(userProfileComplete
      //           ? "User profile complete"
      //           : "User profile incomplete")
      //       : const Loading(white: false),
      // ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) =>
            _controller = controller,
        zoomControlsEnabled: false,
        compassEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCurrLocation,
        child: const Icon(Icons.my_location_rounded),
        tooltip: "Your location",
      ),
      drawer: !loading
          ? !errorLoadingProfile
              ? HomeDrawer(userProfileData: userProfileData!)
              : const SizedBox(height: 0.0, width: 0.0)
          : const SizedBox(height: 0.0, width: 0.0),
      onDrawerChanged: (changed) {
        if (!changed) {
          if (ref.watch(profileUpdated)) {
            ref.read(profileUpdated.state).state = false;
            checkUserData().whenComplete(
              () => setState(() => loading = false),
            );
          }
        }
      },
    );
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
