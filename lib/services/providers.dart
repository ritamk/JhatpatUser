import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Used in authentication to preserve the phone number
/// between phone number field and otp field.
final phoneNumProvider = StateProvider<String>((ref) => "");

/// Used to switch between phone and otp fields in auth page.
final otpScreenBoolProvider = StateProvider<bool>((ref) => false);

/// Stores token returned from the initial login/register API.
final tokenProvider = StateProvider<String?>((ref) => null);

/// Used to tell the Home page after the closing of the
/// drawer that the profile has been updated and
/// that the data needs to be reloaded.
final profileUpdated = StateProvider<bool>((ref) => false);
