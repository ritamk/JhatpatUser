import 'dart:convert';

import 'package:http/http.dart';
import 'package:jhatpat/models/user.dart';

class DatabaseService {
  final String _apiSite = "https://demo.karukatha.com/apis";
  final String _postLogRegUrl = "/login_register";

  Future<UserProfileData?> postLoginRegister({String? phNum}) async {
    Uri url = Uri.parse(_apiSite + _postLogRegUrl);
    try {
      Response response = await post(
        url,
        body: jsonEncode(
          <String, String>{
            "phone_no": phNum!,
            "type": "1",
          },
        ),
      );
      print(response.body);
      Map decodedResponse = jsonDecode(response.body);
      if (decodedResponse["success"] == "1") {
        return UserProfileData(
          phone: decodedResponse["data"]["phone"],
          token: decodedResponse["data"]["token"],
          otp: decodedResponse["data"]["otp"],
        );
      } else {
        return Future.error("Something went wrong, please try again");
      }
    } catch (e) {
      print("postLoginRegister: ${e.toString()}");
      return Future.error(e.toString());
    }
  }
}
