import 'package:flutter/material.dart';
import 'package:jhatpat/views/auth/phone_num_field.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    "assets/images/LogoWTxtSmaller.png",
                    scale: 4,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(22.0),
                    child: Material(
                        child: PhoneNumberField(),
                        type: MaterialType.transparency),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40.0, width: 0.0)),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Image.asset("assets/images/BottomBlack.png"),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(fontSize: 12.0, color: Colors.white54),
                        children: <InlineSpan>[
                          TextSpan(
                              text: "By signing up, you have agreed to our"),
                          TextSpan(
                            text: "\nTerms of Use",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: " & "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
