import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/shared/auth_text_field.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/providers.dart';
import 'package:jhatpat/shared/snackbars.dart';

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
  bool resendOtpLoading = false;

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
            validator: validation,
            onChanged: (val) => _otp = val,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (val) => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 20.0, width: 0.0),
          Consumer(builder: (context, ref, __) {
            return Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: resendOtpButton(context, ref),
                child: !resendOtpLoading
                    ? const Text(
                        "Resent OTP",
                        style: TextStyle(
                            color: Colors.black54, fontWeight: FontWeight.bold),
                      )
                    : const Loading(white: false),
              ),
            );
          }),
          const SizedBox(height: 20.0, width: 0.0),
          Consumer(builder: (context, ref, __) {
            return MaterialButton(
              onPressed: () => verifyButton(context, ref),
              child: !loading
                  ? const Text(
                      "Verify",
                      style: TextStyle(fontSize: 16.0),
                    )
                  : const Loading(white: true),
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

  resendOtpButton(BuildContext context, WidgetRef ref) async {
    final String? token = ref.watch(tokenProvider);

    setState(() => resendOtpLoading = true);
    try {
      final bool resentOrNot = await DatabaseService(token: token)
          .getResendOtp()
          .whenComplete(() => setState(() => resendOtpLoading = false));

      commonSnackbar(
          resentOrNot
              ? "OTP resent"
              : "OTP could not be resent,\nPlease try again",
          context);
    } catch (e) {
      commonSnackbar("Something went wrong, please try again", context);
    }
  }

  verifyButton(BuildContext context, WidgetRef ref) async {
    final String? token = ref.watch(tokenProvider);

    if (_otpGlobalKey.currentState!.validate()) {
      setState(() => loading = true);

      if (token != null) {
        try {
          final bool verifiedOrNot = await DatabaseService(token: token)
              .postVerifyOtp(_otp)
              .whenComplete(() => setState(() => loading = false));

          commonSnackbar(
              verifiedOrNot ? "OTP Verified" : "Couldn't verify OTP", context);

          ref.read(otpScreenBoolProvider.state).state = false;
        } catch (e) {
          commonSnackbar("Something went wrong, please try again", context);
        }
      } else {
        commonSnackbar("No phone number provided", context);
        setState(() => loading = false);
      }
    }
  }

  String? validation(val) {
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
  }

  @override
  void dispose() {
    _otpFocusNode.dispose();
    super.dispose();
  }
}