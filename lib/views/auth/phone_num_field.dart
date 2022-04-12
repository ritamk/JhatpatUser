import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jhatpat/models/user.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/shared/text_field_deco.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/services/providers.dart';
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
          Card(
            shadowColor: Colors.black38,
            elevation: 6.0,
            child: TextFormField(
              decoration: authTextInputDecoration(
                  "Phone number", Icons.phone_android, "+91 "),
              style: const TextStyle(color: Colors.black, fontSize: 16.0),
              focusNode: _phoneFocusNode,
              validator: validation,
              onChanged: (val) => _phoneNum = val,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (val) => FocusScope.of(context).unfocus(),
            ),
          ),
          const SizedBox(height: 20.0, width: 0.0),
          Consumer(builder: (context, ref, __) {
            return MaterialButton(
              onPressed: () => continueButton(context, ref),
              child: !loading
                  ? const Text(
                      "Continue",
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

  void continueButton(BuildContext context, WidgetRef ref) async {
    if (_phNoGlobalKey.currentState!.validate()) {
      setState(() => loading = true);

      try {
        final UserLoginRegData? result =
            await DatabaseService().postLoginRegister(phNum: _phoneNum);
        if (result.runtimeType == UserLoginRegData) {
          setState(() {
            loading = false;
            ref.read(otpScreenBoolProvider.state).state = true;
            ref.read(tokenProvider.state).state = result?.token;
          });
        } else {
          commonSnackbar("Something went wrong, please try again", context);
          setState(() => loading = false);
        }
        setState(() {});
      } catch (e) {
        commonSnackbar(e.toString(), context);
        setState(() => loading = false);
      }

      ref.read(phoneNumProvider.state).state = _phoneNum;
    }
  }

  String? validation(val) {
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
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    super.dispose();
  }
}
