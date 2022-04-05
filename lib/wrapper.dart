import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jhatpat/views/auth/auth_page.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({Key? key}) : super(key: key);

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  final int _wrapperDuration = 2;

  @override
  void initState() {
    super.initState();
    splashMethod();
  }

  Future splashMethod() async {
    await Future.delayed(Duration(seconds: _wrapperDuration)).whenComplete(
      () => Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => const AuthenticationPage()),
          (route) => false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Image.asset(
                "assets/images/LogoWTxt.png",
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              "assets/images/SplashBottom.png",
            ),
          ),
        ],
      ),
    );
  }
}
