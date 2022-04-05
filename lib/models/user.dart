class UserProfileData {
  final String phone;
  final String? token;
  final String? name;
  final String? email;
  final String? modified;

  UserProfileData({
    required this.phone,
    this.token,
    this.name,
    this.email,
    this.modified,
  });
}

class UserLoginRegData {
  final String phone;
  final String token;
  final String? otp;

  UserLoginRegData({
    required this.phone,
    required this.token,
    this.otp,
  });
}

class UserLocationData {
  final String? phone;
  final String token;
  final String lat;
  final String lon;

  UserLocationData({
    this.phone,
    required this.token,
    required this.lat,
    required this.lon,
  });
}
