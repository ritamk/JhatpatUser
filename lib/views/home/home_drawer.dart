import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jhatpat/models/user.dart';
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

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({Key? key, required this.userProfileData}) : super(key: key);
  final UserProfileData userProfileData;

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  late bool profileCompleted;
  bool signingOut = false;

  @override
  void initState() {
    super.initState();
    profileCompleted = widget.userProfileData.name!.isNotEmpty ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  maxRadius: 40.0,
                  backgroundImage:
                      Image.asset("assets/images/UserProfileDefault.png").image,
                ),
                if (profileCompleted)
                  RichText(
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                            text: "\n${widget.userProfileData.name!}",
                            style: const TextStyle(
                                fontSize: 20.0,
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: "\n${widget.userProfileData.email!}",
                            style: const TextStyle(color: Colors.black45)),
                      ],
                    ),
                  )
                else
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => ProfilePage(
                            profileCompleted: false,
                            userProfileData: widget.userProfileData,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Complete your profile",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => profileCompleted
                      ? ProfilePage(
                          profileCompleted: true,
                          userProfileData: widget.userProfileData,
                        )
                      : ProfilePage(
                          profileCompleted: false,
                          userProfileData: widget.userProfileData,
                        ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Payment Methods"),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                    builder: (context) => const PaymentMethodsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("History"),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_offer),
            title: const Text("Apply promo code"),
            onTap: () {
              // Navigator.of(context).push(
              //   CupertinoPageRoute(builder: (context) => ),
              // );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("My Addresses"),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => const AddressPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text("Online Support"),
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => const SupportPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.power_settings_new),
            title: !signingOut
                ? const Text("Log Out")
                : const Loading(white: false),
            onTap: () => signOutMethod(),
          ),
        ],
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