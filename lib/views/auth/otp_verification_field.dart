import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jhatpat/shared/auth_text_field.dart';
import 'package:jhatpat/shared/providers.dart';

class OTPVerificationField extends StatefulWidget {
  const OTPVerificationField({Key? key}) : super(key: key);

  @override
  State<OTPVerificationField> createState() => OTPVerificationFieldState();
}

class OTPVerificationFieldState extends State<OTPVerificationField> {
  final GlobalKey<FormState> _otpGlobalKey = GlobalKey<FormState>();
  String _otp = "";
  final FocusNode _otpFocusNode = FocusNode();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _otpGlobalKey,
      child: Column(
        children: <Widget>[
          const Text(
            "OTP Verification",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          Consumer(builder: (context, ref, __) {
            return Text(
              "\nPlease check your messages for the OTP"
              "\nthat has been sent to +91${ref.watch(phoneNumProvider)}",
              style: const TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            );
          }),
          const SizedBox(height: 30.0, width: 0.0),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: authTextInputDecoration("4 digit OTP", Icons.lock, ""),
            style: const TextStyle(color: Colors.black, fontSize: 16.0),
            focusNode: _otpFocusNode,
            validator: (val) {
              if (val != null) {
                if (val.isEmpty) {
                  return "Please enter the OTP";
                } else if (val.isNotEmpty &&
                    (val.length < 4 ||
                        val.length > 4 ||
                        !val.contains(RegExp("[0-9]")))) {
                  return "Please enter a valid OTP";
                } else {
                  return null;
                }
              } else {
                return "Please enter the OTP";
              }
            },
            onChanged: (val) => _otp = val,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (val) => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 20.0, width: 0.0),
          Consumer(builder: (context, ref, __) {
            return MaterialButton(
              onPressed: () => verifyButton(context, ref),
              child: const Text(
                "Verify",
                style: TextStyle(fontSize: 16.0),
              ),
              minWidth: double.infinity,
              elevation: 0.0,
              focusElevation: 0.0,
              highlightElevation: 0.0,
              color: Colors.black,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
            );
          }),
        ],
      ),
    );
  }

  verifyButton(BuildContext context, WidgetRef ref) {
    if (_otpGlobalKey.currentState!.validate()) {
      setState(() => ref.read(otpScreenBoolProvider.state).state = false);
    }
  }

  @override
  void dispose() {
    _otpFocusNode.dispose();
    super.dispose();
  }
}
