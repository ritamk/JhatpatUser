import 'package:shared_preferences/shared_preferences.dart';

class UserSharedPreferences {
  static SharedPreferences? sharedPreferences;
  static const String _userTokenKey = "userTokenKey";
  static const String _userPhoneNumKey = "userPhoneNumKey";

  static Future init() async =>
      sharedPreferences = await SharedPreferences.getInstance();

  static Future setUserToken(String token) async {
    try {
      await sharedPreferences!.setString(_userTokenKey, token);
    } catch (e) {
      print("setUserToken: ${e.toString()}");
      Future.error("Something went wrong while"
          "\nsaving user data on device");
    }
  }

  static String? getUserToken() {
    try {
      return sharedPreferences!.getString(_userTokenKey);
    } catch (e) {
      return null;
    }
  }

  static Future setUserPhoneNum(String phoneNum) async {
    try {
      await sharedPreferences!.setString(_userPhoneNumKey, phoneNum);
    } catch (e) {
      print("setUserToken: ${e.toString()}");
      Future.error("Something went wrong while"
          "\nsaving user data on device");
    }
  }

  static String? getUserPhoneNum() {
    try {
      return sharedPreferences!.getString(_userPhoneNumKey);
    } catch (e) {
      return null;
    }
  }
}
