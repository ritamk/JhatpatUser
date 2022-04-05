import 'dart:convert';

import 'package:http/http.dart';
import 'package:jhatpat/models/user.dart';

class DatabaseService {
  DatabaseService({this.token});
  final String? token;

  final String _apiSite = "https://demo.karukatha.com/apis/";
  final String _postLogRegUrl = "login_register";
  final String _postOtpVerification = "verifyOtp";
  final String _getResendOtp = "resendOtp";

  Future<UserLoginRegData?> postLoginRegister({String? phNum}) async {
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
        return UserLoginRegData(
          phone: decodedResponse["data"]["phone"],
          token: decodedResponse["data"]["token"],
        );
      } else {
        return Future.error("Something went wrong, please try again");
      }
    } catch (e) {
      print("postLoginRegister: ${e.toString()}");
      return Future.error(e.toString());
    }
  }

  Future<bool> postVerifyOtp(String otp) async {
    Uri url = Uri.parse(_apiSite + _postOtpVerification);
    try {
      Response response = await post(
        url,
        headers: {"user-token": token!},
        body: jsonEncode(
          <String, String>{
            "otp": otp,
          },
        ),
      );
      print(response.body);
      Map decodedResponse = jsonDecode(response.body);
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("postVerifyOtp: ${e.toString()}");
      return Future.error(e.toString());
    }
  }

  Future<bool> getResendOtp() async {
    Uri url = Uri.parse(_apiSite + _getResendOtp);
    try {
      Response response = await get(url, headers: {"user-token": token!});
      print(response.body);
      Map decodedResponse = jsonDecode(response.body);
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("getResendOtp: ${e.toString()}");
      return Future.error(e.toString());
    }
  }
}
