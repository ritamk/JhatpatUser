import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jhatpat/models/user.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/providers.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';
import 'package:jhatpat/views/history/history.dart';
import 'package:jhatpat/views/payment/payment.dart';
import 'package:jhatpat/views/profile/address.dart';
import 'package:jhatpat/views/profile/profile.dart';
import 'package:jhatpat/views/settings/settings.dart';
import 'package:jhatpat/views/support/support.dart';
import 'package:jhatpat/wrapper.dart';

class HomeDrawer extends ConsumerStatefulWidget {
  const HomeDrawer({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends ConsumerState<HomeDrawer> {
  bool loading = true;
  bool signingOut = false;
  bool userProfileComplete = false;
  bool errorLoadingProfile = false;
  UserProfileData? userProfileData;
  final TextStyle _sectionStyle = const TextStyle(
      color: Color.fromARGB(202, 255, 255, 255), fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    ref.read(profileUpdated)
        ? checkUserData().whenComplete(() => setState((() {
              loading = false;
              ref.read(profileUpdated.state).state == false;
            })))
        : setState(() => loading = false);
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
    return Drawer(
      backgroundColor: Colors.black,
      child: !loading
          ? ListView(
              children: <Widget>[
                DrawerHeader(
                  child: !errorLoadingProfile
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CircleAvatar(
                              maxRadius: 40.0,
                              backgroundImage: Image.asset(
                                      "assets/images/UserProfileDefault.png")
                                  .image,
                            ),
                            if (userProfileComplete)
                              RichText(
                                text: TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                        text: "\n${userProfileData!.name!}",
                                        style: const TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                      text: "\n${userProfileData!.email!}",
                                      style: const TextStyle(
                                          color: Colors.white54),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              )
                            else
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => ProfilePage(
                                        profileCompleted: false,
                                        userProfileData: userProfileData!,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Complete your profile",
                                  style: TextStyle(color: Colors.blue.shade100),
                                ),
                              ),
                          ],
                        )
                      : const Icon(
                          Icons.error,
                          size: 50.0,
                          color: Colors.white,
                        ),
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.white60),
                  title: Text("Profile", style: _sectionStyle),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => userProfileComplete
                            ? ProfilePage(
                                profileCompleted: true,
                                userProfileData: userProfileData!,
                              )
                            : ProfilePage(
                                profileCompleted: false,
                                userProfileData: userProfileData!,
                              ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment, color: Colors.white60),
                  title: Text(
                    "Payment Methods",
                    style: _sectionStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => const PaymentMethodsPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.white60),
                  title: Text(
                    "History",
                    style: _sectionStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => const HistoryPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_offer, color: Colors.white60),
                  title: Text(
                    "Apply promo code",
                    style: _sectionStyle,
                  ),
                  onTap: () {
                    // Navigator.of(context).push(
                    //   CupertinoPageRoute(builder: (context) => ),
                    // );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white60),
                  title: Text(
                    "My Addresses",
                    style: _sectionStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => const AddressPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white60),
                  title: Text(
                    "Settings",
                    style: _sectionStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.support_agent, color: Colors.white60),
                  title: Text("Online Support", style: _sectionStyle),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => const SupportPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.power_settings_new,
                      color: Colors.white60),
                  title: !signingOut
                      ? Text(
                          "Log Out",
                          style: _sectionStyle,
                        )
                      : const Loading(white: true),
                  onTap: () => signOutMethod(),
                ),
              ],
            )
          : const Center(
              child: Loading(white: true, rad: 14.0),
            ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0))),
    );
  }

  void signOutMethod() async {
    setState(() => signingOut = true);
    try {
      UserSharedPreferences.setLoggedInOrNot(false)
          .whenComplete(() => UserSharedPreferences.setUserToken(""))
          .whenComplete(() => UserSharedPreferences.setUserPhoneNum(""));
      await Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => const WrapperPage()),
          (route) => false);
    } catch (e) {
      commonSnackbar(
          "Something went wrong, couldn't properly sign-out", context);
    }
    setState(() => signingOut = false);
  }
}


// const CircleAvatar(
  //   maxRadius: 50.0,
  //   child: Icon(
  //     Icons.person_outline_rounded,
  //     size: 80.0,
  //     color: Colors.white,
  //   ),
  //   backgroundColor: Colors.grey,
// ),