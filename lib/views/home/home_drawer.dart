import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jhatpat/models/user.dart';
import 'package:jhatpat/views/profile/profile.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({Key? key, required this.userProfileData}) : super(key: key);
  final UserProfileData userProfileData;

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  late bool profileCompleted;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text("Welcome\n",
                    style: TextStyle(fontSize: 20.0, color: Colors.black54)),
                profileCompleted
                    ? Text(widget.userProfileData.name!)
                    : TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) =>
                                  const ProfilePage(profileCompleted: false),
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
                      ? const ProfilePage(profileCompleted: true)
                      : const ProfilePage(profileCompleted: false),
                ),
              );
            },
          ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    );
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