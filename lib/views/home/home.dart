import 'package:flutter/material.dart';
import 'package:jhatpat/models/user.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  bool userProfileComplete = false;

  @override
  void initState() {
    super.initState();
    checkUserData().whenComplete(
      () => setState(() => loading = false),
    );
  }

  Future checkUserData() async {
    UserProfileData? userProfileData;
    try {
      userProfileData =
          await DatabaseService(token: UserSharedPreferences.getUserToken())
              .getProfileDetails();

      if (userProfileData.runtimeType == UserProfileData) {
        if (userProfileData!.name!.isEmpty) {}
      } else {
        setState(() => userProfileComplete = true);
      }
    } catch (e) {
      commonSnackbar(e.toString(), context);
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
    );
  }
}
