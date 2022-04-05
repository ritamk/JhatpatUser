import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jhatpat/models/user.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/shared/auth_text_field.dart';
import 'package:jhatpat/shared/providers.dart';
import 'package:jhatpat/shared/shared_pref.dart';
import 'package:jhatpat/shared/snackbars.dart';

class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({Key? key}) : super(key: key);

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final GlobalKey<FormState> _phNoGlobalKey = GlobalKey<FormState>();
  String _phoneNum = "";
  final FocusNode _phoneFocusNode = FocusNode();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
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
          Consumer(builder: (context, ref, __) {
            return MaterialButton(
              onPressed: () => continueButton(context, ref),
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
            );
          }),
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

  continueButton(BuildContext context, WidgetRef ref) async {
    if (_phNoGlobalKey.currentState!.validate()) {
      ref.read(phoneNumProvider.state).state = _phoneNum;

      try {
        final UserProfileData? result =
            await DatabaseService().postLoginRegister(phNum: _phoneNum);
        if (result.runtimeType == UserProfileData) {
          await UserSharedPreferences.setUserToken(result!.token!)
              .whenComplete(() => loading = false);
        }
      } catch (e) {
        commonSnackbar(e.toString(), context);
      }

      setState(() => ref.read(otpScreenBoolProvider.state).state = true);
    }
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    super.dispose();
  }
}
