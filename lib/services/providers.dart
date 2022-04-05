import 'package:flutter_riverpod/flutter_riverpod.dart';

final phoneNumProvider = StateProvider<String>((ref) => "");

final otpScreenBoolProvider = StateProvider<bool>((ref) => false);

final tokenProvider = StateProvider<String?>((ref) => null);
