import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jhatpat/views/support/privacy_pol.dart';
import 'package:jhatpat/views/support/terms_cond.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text("Terms and Conditions"),
              onTap: () => Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => const TermsAndConditionsPage())),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text("Privacy Policy"),
              onTap: () => Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => const PrivacyPolicyPage())),
            ),
          ),
        ],
        scrollBehavior: const ScrollBehavior(
            androidOverscrollIndicator: AndroidOverscrollIndicator.stretch),
      ),
    );
  }
}
