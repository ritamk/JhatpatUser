import 'package:flutter/material.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/shared/auth_text_field.dart';
import 'package:jhatpat/shared/snackbars.dart';

class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    Key? key,
  }) : super(key: key);

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final GlobalKey<FormState> _phNoGlobalKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _otpGlobalKey = GlobalKey<FormState>();
  String _phoneNum = "";
  String _otp = "";
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  bool _otpScreen = false;

  @override
  Widget build(BuildContext context) {
    // OTP Form
    if (_otpScreen) {
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
            Text(
              "\nPlease check your messages for the OTP"
              "\nthat has been sent to +91$_phoneNum",
              style: const TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0, width: 0.0),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration:
                  authTextInputDecoration("4 digit OTP", Icons.lock, ""),
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
            MaterialButton(
              onPressed: () => verifyButton(context),
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
            ),
          ],
        ),
      );
    }

    // Phone Form
    else {
      return Form(
        key: _phNoGlobalKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: authTextInputDecoration(
                  "Phone number", Icons.phone_android, "+91 "),
              style: const TextStyle(color: Colors.black, fontSize: 16.0),
              focusNode: _phoneFocusNode,
              validator: (val) {
                if (val != null) {
                  if (val.isEmpty) {
                    return "Please enter your phone number";
                  } else if (val.isNotEmpty &&
                      (val.length < 10 ||
                          val.length > 10 ||
                          !val.contains(RegExp("[0-9]")))) {
                    return "Please enter a valid phone number";
                  } else {
                    return null;
                  }
                } else {
                  return "Please enter your phone number";
                }
              },
              onChanged: (val) => _phoneNum = val,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (val) => FocusScope.of(context).unfocus(),
            ),
            const SizedBox(height: 20.0, width: 0.0),
            MaterialButton(
              onPressed: () => continueButton(context),
              child: const Text(
                "Continue",
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
            ),
            const SizedBox(height: 30.0, width: 0.0),
            const Text(
              "You should receive an SMS for verification."
              "\nMessage and data rates may apply.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _otpFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  continueButton(BuildContext context) async {
    if (_phNoGlobalKey.currentState!.validate()) {
      try {
        final String result =
            await DatabaseService().postLoginRegister(phNum: _phoneNum);
        print(result);
      } catch (e) {
        commonSnackbar(e.toString(), context);
      }
      setState(() {
        _otpScreen = true;
      });
    }
  }

  verifyButton(BuildContext context) {
    if (_otpGlobalKey.currentState!.validate()) {
      setState(() {
        _otpScreen = false;
      });
    }
  }
}
