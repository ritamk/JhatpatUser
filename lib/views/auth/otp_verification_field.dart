import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jhatpat/models/user.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/text_field_deco.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/services/providers.dart';
import 'package:jhatpat/shared/snackbars.dart';
import 'package:jhatpat/views/home/home.dart';

class OTPVerificationField extends StatefulWidget {
  const OTPVerificationField({Key? key}) : super(key: key);
  // final Function? homeFxn;

  @override
  State<OTPVerificationField> createState() => OTPVerificationFieldState();
}

class OTPVerificationFieldState extends State<OTPVerificationField> {
  final GlobalKey<FormState> _otpGlobalKey = GlobalKey<FormState>();
  String _otp = "";
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  bool loading = false;
  bool resendOtpLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _otpGlobalKey,
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                const Center(
                  child: Text(
                    "OTP Verification",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  top: 0.0,
                  bottom: 0.0,
                  left: 0.0,
                  child: Consumer(builder: (context, ref, _) {
                    return IconButton(
                      padding: const EdgeInsets.all(0.0),
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          ref.read(otpScreenBoolProvider.state).state = false,
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.black),
                    );
                  }),
                ),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, __) {
              return Text(
                "\nPlease check your messages for the OTP"
                "\nthat has been sent to +91${ref.watch(phoneNumProvider)}",
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              );
            },
          ),
          const SizedBox(height: 30.0, width: 0.0),
          Card(
            shadowColor: Colors.black38,
            elevation: 6.0,
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration:
                  authTextInputDecoration("4 digit OTP", Icons.lock, null),
              style: const TextStyle(color: Colors.black, fontSize: 16.0),
              focusNode: _otpFocusNode,
              validator: validation,
              onChanged: (val) => _otp = val,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (val) => FocusScope.of(context).unfocus(),
              controller: _otpController,
            ),
          ),
          const SizedBox(height: 5.0, width: 0.0),
          Align(
            alignment: Alignment.centerRight,
            child: Consumer(
              builder: (context, ref, __) {
                return TextButton(
                  style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(0.0))),
                  onPressed: () => resendOtpButton(context, ref),
                  child: !resendOtpLoading
                      ? const Text(
                          "Resend OTP",
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold),
                        )
                      : const Loading(white: false),
                );
              },
            ),
          ),
          const SizedBox(height: 5.0, width: 0.0),
          Consumer(
            builder: (context, ref, __) {
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
            },
          ),
        ],
      ),
    );
  }

  void resendOtpButton(BuildContext context, WidgetRef ref) async {
    final String? token = ref.watch(tokenProvider);

    setState(() => resendOtpLoading = true);

    try {
      final UserLoginRegData? result = await DatabaseService()
          .postLoginRegister(phNum: ref.watch(phoneNumProvider));
      if (result.runtimeType == UserLoginRegData) {
        commonSnackbar("OTP resent successfully", context);
        ref.read(tokenProvider.state).state = result?.token;
      } else {
        commonSnackbar("Something went wrong, please try again", context);
      }
    } catch (e) {
      commonSnackbar("e.toString()", context);
      setState(() => loading = false);
    }
    setState(() => resendOtpLoading = false);
  }

  verifyButton(BuildContext context, WidgetRef ref) async {
    final String? token = ref.watch(tokenProvider);

    if (_otpGlobalKey.currentState!.validate()) {
      setState(() => loading = true);

      if (token != null) {
        try {
          final bool verifiedOrNot = await DatabaseService(token: token)
              .postVerifyOtp(_otp)
              .whenComplete(() {
            setState(() => loading = false);
          });

          if (verifiedOrNot) {
            await UserSharedPreferences.setLoggedInOrNot(true)
                .whenComplete(() async =>
                    await UserSharedPreferences.setUserPhoneNum(
                        ref.watch(phoneNumProvider)))
                .whenComplete(
                    () async => await UserSharedPreferences.setUserToken(token))
                .whenComplete(() {
              ref.read(otpScreenBoolProvider.state).state = false;
              ref.read(phoneNumProvider.state).state = "";
              ref.read(tokenProvider.state).state = "";
            }).whenComplete(
              () => Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => const HomePage()),
                  (route) => false),
            );
          } else {
            await UserSharedPreferences.setLoggedInOrNot(false).whenComplete(
                () => commonSnackbar("OTP does not match", context));
            _otp = "";
            _otpController.clear();
          }
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
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }
}
