import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  // bool _loading = true;
  // bool _error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: WebView(
          initialUrl: "https://jhatpat.app/terms-condition",
          zoomEnabled: false,
          // onPageFinished: (String text) =>
          //     setState(() => _loading = false),
          // onWebResourceError: (WebResourceError error) =>
          //     setState(() => _error = true),
        ),
      ),
    );
  }
}
