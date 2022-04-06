import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jhatpat/models/user.dart';
import 'package:jhatpat/services/database/database.dart';
import 'package:jhatpat/services/providers.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/shared/auth_text_field.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbars.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(
      {Key? key, required this.profileCompleted, required this.userProfileData})
      : super(key: key);
  final bool profileCompleted;
  final UserProfileData userProfileData;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = false;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = FocusNode();
  String _name = "";
  late TextEditingController _nameController;
  final FocusNode _emailFocus = FocusNode();
  String _email = "";
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfileData.name);
    _emailController =
        TextEditingController(text: widget.userProfileData.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _globalKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration:
                      authTextInputDecoration("Name", Icons.person, null),
                  style: const TextStyle(color: Colors.black, fontSize: 16.0),
                  focusNode: _nameFocus,
                  validator: (val) =>
                      val != null ? nameValidator(val) : "Please add a name",
                  onChanged: (val) => _name = val,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (val) =>
                      FocusScope.of(context).requestFocus(_emailFocus),
                  maxLength: 20,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                ),
                const SizedBox(height: 10.0, width: 0.0),
                TextFormField(
                  controller: _emailController,
                  decoration:
                      authTextInputDecoration("Email", Icons.mail, null),
                  style: const TextStyle(color: Colors.black, fontSize: 16.0),
                  focusNode: _emailFocus,
                  validator: (val) =>
                      val != null ? emailValidator(val) : "Please add an email",
                  onChanged: (val) => _email = val,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (val) => FocusScope.of(context).unfocus(),
                ),
                const SizedBox(height: 20.0, width: 0.0),
                Consumer(
                  builder: (context, ref, __) {
                    return MaterialButton(
                      onPressed: () => updateButton(context, ref),
                      child: !loading
                          ? const Text(
                              "Update",
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateButton(BuildContext context, WidgetRef ref) async {
    if (_globalKey.currentState!.validate()) {
      setState(() => loading = true);

      try {
        final bool result = await DatabaseService(
                token: UserSharedPreferences.getUserToken()!)
            .postUserDetails(
                _name, _email, UserSharedPreferences.getUserPhoneNum()!, false);
        setState(() => loading = false);
        if (result) {
          commonSnackbar("Profile updated successfully", context);
          ref.read(profileUpdated.state).state = true;
        } else {
          commonSnackbar("Something went wrong, please try again", context);
        }
      } catch (e) {
        commonSnackbar(e.toString(), context);
        setState(() => loading = false);
      }
    }
  }

  String? nameValidator(String val) {
    if (val.isEmpty) {
      return "Please add a name";
    } else {
      if (val.length < 3) {
        return "Name can't be less than 3 letters";
      } else {
        if (!val.contains(RegExp("[A-B]")) && !val.contains(RegExp("[a-b]"))) {
          return "Enter a proper name";
        } else {
          return null;
        }
      }
    }
  }

  String? emailValidator(String val) {
    if (val.isEmpty) {
      return "Please add an email";
    } else {
      if (!val.contains(RegExp("[A-B]")) &&
          !val.contains(RegExp("[a-b]")) &&
          !val.contains(RegExp("[0-9]")) &&
          !val.contains(RegExp("[@, ., +]"))) {
        return "Please enter a proper email address";
      } else {
        return null;
      }
    }
  }
}
