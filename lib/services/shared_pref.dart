import 'package:shared_preferences/shared_preferences.dart';

class UserSharedPreferences {
  static SharedPreferences? sharedPreferences;
  static const String _userTokenKey = "userTokenKey";
  static const String _userPhoneNumKey = "userPhoneNumKey";
  static const String _loggedInKey = "loggedInKey";
  static const String _mapGeoLocKey = "mapgeolocKey";

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
      String? token = sharedPreferences!.getString(_userTokenKey);
      return token != null
          ? token.isEmpty
              ? null
              : token
          : null;
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
      String? num = sharedPreferences!.getString(_userPhoneNumKey);
      return num != null
          ? num.isEmpty
              ? null
              : num
          : null;
    } catch (e) {
      return null;
    }
  }

  static Future setLoggedInOrNot(bool loggedIn) async {
    try {
      await sharedPreferences!.setBool(_loggedInKey, loggedIn);
    } catch (e) {
      print("setLoggedInOrNot: ${e.toString()}");
      Future.error("Something went wrong while"
          "\nsaving user data on device");
    }
  }

  static bool getLoggedInOrNot() {
    try {
      return sharedPreferences!.getBool(_loggedInKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future setMapGeoLoc(double lat, double long) async {
    try {
      await sharedPreferences!
          .setStringList(_mapGeoLocKey, [lat.toString(), long.toString()]);
    } catch (e) {
      print("setMapGeoLoc: ${e.toString()}");
      Future.error("Something went wrong while"
          "\nsaving user data on device");
    }
  }

  static List<double?> getMapGeoLoc() {
    try {
      return [
        double.tryParse(sharedPreferences!.getStringList(_mapGeoLocKey)![0]),
        double.tryParse(sharedPreferences!.getStringList(_mapGeoLocKey)![1])
      ];
    } catch (e) {
      print("getMapGeoLoc: ${e.toString()}");
      return [];
    }
  }
}
