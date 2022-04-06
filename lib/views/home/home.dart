import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: !loading
            ? Text(userProfileComplete
                ? "User profile complete"
                : "User profile incomplete")
            : const Loading(white: false),
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
