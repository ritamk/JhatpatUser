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
  final TextStyle _sectionStyle = const TextStyle(color: Colors.black87);
  final Color _sideLogoCol = Colors.black45;

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
      child: !loading
          ? CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: DrawerHeader(
                    child: !errorLoadingProfile
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                maxRadius: 38.0,
                                backgroundImage: Image.asset(
                                        "assets/images/UserProfileDefault.png")
                                    .image,
                              ),
                              if (userProfileComplete)
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontFamily: "Montserrat"),
                                    children: <InlineSpan>[
                                      TextSpan(
                                        text: "\n${userProfileData!.name!}",
                                        style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: "\n${userProfileData!.email!}",
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
                                    style:
                                        TextStyle(color: Colors.blue.shade100),
                                  ),
                                ),
                            ],
                          )
                        : const Icon(Icons.error,
                            size: 50.0, color: Colors.red),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    leading: Icon(Icons.person, color: _sideLogoCol),
                    title: Text("Profile", style: _sectionStyle),
                    onTap: () {
                      if (!userProfileComplete) {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => ProfilePage(
                              profileCompleted: false,
                              userProfileData: userProfileData!,
                            ),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                              builder: (context) => ProfilePage(
                                    profileCompleted: true,
                                    userProfileData: userProfileData!,
                                  )),
                        );
                      }
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    leading: Icon(Icons.payment, color: _sideLogoCol),
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
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    leading: Icon(Icons.history, color: _sideLogoCol),
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
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    leading: Icon(Icons.local_offer, color: _sideLogoCol),
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
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    leading: Icon(Icons.home, color: _sideLogoCol),
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
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    leading: Icon(Icons.settings, color: _sideLogoCol),
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
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    leading: Icon(Icons.support_agent, color: _sideLogoCol),
                    title: Text("Online Support", style: _sectionStyle),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                            builder: (context) => const SupportPage()),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    leading:
                        Icon(Icons.power_settings_new, color: _sideLogoCol),
                    title: !signingOut
                        ? Text(
                            "Log Out",
                            style: _sectionStyle,
                          )
                        : const Loading(white: false),
                    onTap: () => signOutMethod(),
                  ),
                ),
              ],
              // child: ListView(
              //   children: <Widget>[
              //     DrawerHeader(
              //       child: !errorLoadingProfile
              //           ? Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               mainAxisSize: MainAxisSize.min,
              //               crossAxisAlignment: CrossAxisAlignment.center,
              //               children: <Widget>[
              //                 CircleAvatar(
              //                   maxRadius: 38.0,
              //                   backgroundImage: Image.asset(
              //                           "assets/images/UserProfileDefault.png")
              //                       .image,
              //                 ),
              //                 if (userProfileComplete)
              //                   RichText(
              //                     text: TextSpan(
              //                       style: const TextStyle(
              //                           color: Colors.black87,
              //                           fontFamily: "Montserrat"),
              //                       children: <InlineSpan>[
              //                         TextSpan(
              //                           text: "\n${userProfileData!.name!}",
              //                           style: const TextStyle(
              //                               fontSize: 18.0,
              //                               fontWeight: FontWeight.bold),
              //                         ),
              //                         TextSpan(
              //                           text: "\n${userProfileData!.email!}",
              //                         ),
              //                       ],
              //                     ),
              //                     textAlign: TextAlign.center,
              //                   )
              //                 else
              //                   TextButton(
              //                     onPressed: () {
              //                       Navigator.of(context).pop();
              //                       Navigator.of(context).push(
              //                         CupertinoPageRoute(
              //                           builder: (context) => ProfilePage(
              //                             profileCompleted: false,
              //                             userProfileData: userProfileData!,
              //                           ),
              //                         ),
              //                       );
              //                     },
              //                     child: Text(
              //                       "Complete your profile",
              //                       style:
              //                           TextStyle(color: Colors.blue.shade100),
              //                     ),
              //                   ),
              //               ],
              //             )
              //           : const Icon(Icons.error,
              //               size: 50.0, color: Colors.red),
              //     ),
              //     ListTile(
              //       leading: Icon(Icons.person, color: _sideLogoCol),
              //       title: Text("Profile", style: _sectionStyle),
              //       onTap: () {
              //         if (!userProfileComplete) {
              //           Navigator.of(context).push(
              //             CupertinoPageRoute(
              //               builder: (context) => ProfilePage(
              //                 profileCompleted: false,
              //                 userProfileData: userProfileData!,
              //               ),
              //             ),
              //           );
              //         } else {
              //           Navigator.of(context).push(
              //             CupertinoPageRoute(
              //                 builder: (context) => ProfilePage(
              //                       profileCompleted: true,
              //                       userProfileData: userProfileData!,
              //                     )),
              //           );
              //         }
              //       },
              //     ),
              //     ListTile(
              //       leading: Icon(Icons.payment, color: _sideLogoCol),
              //       title: Text(
              //         "Payment Methods",
              //         style: _sectionStyle,
              //       ),
              //       onTap: () {
              //         Navigator.of(context).push(
              //           CupertinoPageRoute(
              //               builder: (context) => const PaymentMethodsPage()),
              //         );
              //       },
              //     ),
              //     ListTile(
              //       leading: Icon(Icons.history, color: _sideLogoCol),
              //       title: Text(
              //         "History",
              //         style: _sectionStyle,
              //       ),
              //       onTap: () {
              //         Navigator.of(context).push(
              //           CupertinoPageRoute(
              //               builder: (context) => const HistoryPage()),
              //         );
              //       },
              //     ),
              //     ListTile(
              //       leading: Icon(Icons.local_offer, color: _sideLogoCol),
              //       title: Text(
              //         "Apply promo code",
              //         style: _sectionStyle,
              //       ),
              //       onTap: () {
              //         // Navigator.of(context).push(
              //         //   CupertinoPageRoute(builder: (context) => ),
              //         // );
              //       },
              //     ),
              //     ListTile(
              //       leading: Icon(Icons.home, color: _sideLogoCol),
              //       title: Text(
              //         "My Addresses",
              //         style: _sectionStyle,
              //       ),
              //       onTap: () {
              //         Navigator.of(context).push(
              //           CupertinoPageRoute(
              //               builder: (context) => const AddressPage()),
              //         );
              //       },
              //     ),
              //     ListTile(
              //       leading: Icon(Icons.settings, color: _sideLogoCol),
              //       title: Text(
              //         "Settings",
              //         style: _sectionStyle,
              //       ),
              //       onTap: () {
              //         Navigator.of(context).push(
              //           CupertinoPageRoute(
              //               builder: (context) => const SettingsPage()),
              //         );
              //       },
              //     ),
              //     ListTile(
              //       leading: Icon(Icons.support_agent, color: _sideLogoCol),
              //       title: Text("Online Support", style: _sectionStyle),
              //       onTap: () {
              //         Navigator.of(context).push(
              //           CupertinoPageRoute(
              //               builder: (context) => const SupportPage()),
              //         );
              //       },
              //     ),
              //     ListTile(
              //       leading:
              //           Icon(Icons.power_settings_new, color: _sideLogoCol),
              //       title: !signingOut
              //           ? Text(
              //               "Log Out",
              //               style: _sectionStyle,
              //             )
              //           : const Loading(white: false),
              //       onTap: () => signOutMethod(),
              //     ),
              //   ],
              // ),
              scrollBehavior: const ScrollBehavior(
                  androidOverscrollIndicator:
                      AndroidOverscrollIndicator.stretch),
            )
          : const Center(
              child: Loading(white: false, rad: 14.0),
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