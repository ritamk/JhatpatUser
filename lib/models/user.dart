class UserProfileData {
  final String phone;
  final String? token;
  final String? name;
  final String? email;
  final String? otp;
  final String? modified;

  UserProfileData({
    required this.phone,
    this.token,
    this.name,
    this.email,
    this.otp,
    this.modified,
  });
}
