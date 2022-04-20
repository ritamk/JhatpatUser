import 'package:flutter/material.dart';
import 'package:jhatpat/shared/error_widget.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  // bool _loading = true;
  // bool _error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: WebView(
            initialUrl: "https://jhatpat.app/privacy-policy",
            zoomEnabled: false,
            // onPageFinished: (String text) =>
            //     setState(() => _loading = false),
            // onWebResourceError: (WebResourceError error) =>
            //     setState(() => _error = true),
          )),
    );
  }
}
