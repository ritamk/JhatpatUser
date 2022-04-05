import 'dart:convert';

import 'package:http/http.dart';

class DatabaseService {
  final String _apiSite = "https://demo.karukatha.com/apis";
  final String _logRegUrl = "/login_register";

  // Future<String>
  postLoginRegister({String? phNum}) async {
    Uri url = Uri.parse(_apiSite + _logRegUrl);
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
      return decodedResponse["success"] == "1"
          ? decodedResponse["data"]["token"]
          : Future.error("Something went wrong, please try again");
    } catch (e) {
      print("postLoginRegister: ${e.toString()}");
      return Future.error(e.toString());
    }
  }
}
