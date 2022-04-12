import 'dart:convert';

import 'package:http/http.dart';
import 'package:jhatpat/models/user.dart';

const String API_KEY = "AIzaSyB-vTdHvOxBzpybH3xVJTuIASuicCfPv8c";

class DatabaseService {
  DatabaseService({this.token});
  final String? token;

  final String _sthWentWrong = "Something went wrong, please try again";

  final String _apiSite = "https://demo.karukatha.com/apis/";
  final String _postLogRegUrl = "login_register";
  final String _postOtpVerification = "verifyOtp";
  final String _getResendOtp = "resendOtp";
  final String _postUpdateLocation = "updateCurrentLocation";
  final String _getUserDetails = "getUserProfileDetails";
  final String _postUserDetails = "updateUserDetails";

  Future<UserLoginRegData?> postLoginRegister({String? phNum}) async {
    final Uri url = Uri.parse(_apiSite + _postLogRegUrl);
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
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      if (decodedResponse["success"] == "1") {
        return UserLoginRegData(
          phone: decodedResponse["data"]["phone"],
          token: decodedResponse["data"]["token"],
        );
      } else {
        return Future.error(_sthWentWrong);
      }
    } catch (e) {
      print("postLoginRegister: ${e.toString()}");
      return Future.error(e.toString());
    }
  }

  Future<bool> postVerifyOtp(String otp) async {
    final Uri url = Uri.parse(_apiSite + _postOtpVerification);
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
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
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
    final Uri url = Uri.parse(_apiSite + _getResendOtp);
    try {
      Response response = await get(
        url,
        headers: {"user-token": token!},
      );
      print(response.body);
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
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

  Future<UserLocationData> postCurrentLocation(String lat, String lon) async {
    final Uri url = Uri.parse(_apiSite + _postUpdateLocation);
    try {
      Response response = await post(
        url,
        headers: {"user-token": token!},
        body: jsonEncode(
          {
            "latitude": lat,
            "longitude": lon,
          },
        ),
      );
      print(response.body);
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      if (decodedResponse["success"] == "1") {
        return UserLocationData(
            token: decodedResponse["data"]["token"],
            lat: decodedResponse["data"]["lat"],
            lon: decodedResponse["data"]["lon"]);
      } else {
        return Future.error(_sthWentWrong);
      }
    } catch (e) {
      print("postCurrentLocation: ${e.toString()}");
      return Future.error(e.toString());
    }
  }

  Future<UserProfileData?> getProfileDetails() async {
    final Uri url = Uri.parse(_apiSite + _getUserDetails);
    try {
      Response response = await get(
        url,
        headers: {"user-token": token!},
      );
      print(response.body);
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      if (decodedResponse["success"] == "1") {
        return UserProfileData(
          phone: decodedResponse["data"]["User_Profile_Details"]["user_phone"],
          name: decodedResponse["data"]["User_Profile_Details"]["user_name"],
          email: decodedResponse["data"]["User_Profile_Details"]["user_email"],
          modified: decodedResponse["data"]["User_Profile_Details"]["modified"],
        );
      } else {
        return Future.error(_sthWentWrong);
      }
    } catch (e) {
      print("getProfileDetails: ${e.toString()}");
      return Future.error(e.toString());
    }
  }

  Future<bool> postUserDetails(
      String name, String email, String phNum, bool edit) async {
    final Uri url = Uri.parse(_apiSite + _postUserDetails);
    try {
      Response response = await post(
        url,
        headers: {"user-token": token!},
        body: jsonEncode(
          {
            "user_name": name,
            "user_email": email,
            "user_phone": phNum,
            "edit_flag": edit ? "1" : "0",
          },
        ),
      );
      print(response.body);
      Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      if (decodedResponse["success"] == "1") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("postCurrentLocation: ${e.toString()}");
      return Future.error(e.toString());
    }
  }
}
