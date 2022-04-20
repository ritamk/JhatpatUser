import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jhatpat/services/providers.dart';
import 'package:jhatpat/views/about/privacy_pol.dart';
import 'package:jhatpat/views/about/terms_cond.dart';
import 'package:jhatpat/views/auth/otp_verification_field.dart';
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
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Consumer(
                      builder: (context, ref, __) {
                        bool otpBool = ref.watch(otpScreenBoolProvider);
                        return Material(
                          child: otpBool
                              ? const OTPVerificationField()
                              : const PhoneNumberField(),
                          type: MaterialType.transparency,
                        );
                      },
                    ),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text("By signing up, you have agreed to our",
                            style: TextStyle(
                                fontSize: 12.0, color: Colors.white54)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkWell(
                              child: const Text("Terms and Conditions",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold)),
                              onTap: () => Navigator.of(context).push(
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          const TermsAndConditionsPage())),
                            ),
                            const Text(" & ",
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.white54)),
                            InkWell(
                              child: const Text("Privacy Policy",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold)),
                              onTap: () => Navigator.of(context).push(
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          const PrivacyPolicyPage())),
                            )
                          ],
                        ),
                      ],
                    ),
                    // child: RichText(
                    //   textAlign: TextAlign.center,
                    //   text: const TextSpan(
                    //     style: TextStyle(fontSize: 12.0, color: Colors.white54),
                    //     children: <InlineSpan>[
                    //       TextSpan(
                    //           text: "By signing up, you have agreed to our"),
                    //       TextSpan(
                    //         text: "\nTerms of Use",
                    //         style: TextStyle(
                    //             color: Colors.white70,
                    //             fontWeight: FontWeight.bold),
                    //       ),
                    //       TextSpan(text: " & "),
                    //       TextSpan(
                    //         text: "Privacy Policy",
                    //         style: TextStyle(
                    //             color: Colors.white70,
                    //             fontWeight: FontWeight.bold),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ),
                ],
              ),
            ),
          ),
        ],
        scrollBehavior: const ScrollBehavior(
            androidOverscrollIndicator: AndroidOverscrollIndicator.stretch),
      ),
    );
  }
}
