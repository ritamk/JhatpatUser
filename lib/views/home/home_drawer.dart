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
  @override
  void initState() {
    super.initState();
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
                // const CircleAvatar(
                //   maxRadius: 50.0,
                //   child: Icon(
                //     Icons.person_outline_rounded,
                //     size: 80.0,
                //     color: Colors.white,
                //   ),
                //   backgroundColor: Colors.grey,
                // ),
                const Text("Welcome\n",
                    style: TextStyle(fontSize: 20.0, color: Colors.black54)),
                widget.userProfileData.name!.isNotEmpty
                    ? Text(widget.userProfileData.name!)
                    : TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) =>
                                  const ProfilePage(profileCompleted: false)));
                        },
                        child: const Text(
                          "Complete your profile",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
              ],
            ),
          ),
          // const ListTile(

          // ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    );
  }
}
