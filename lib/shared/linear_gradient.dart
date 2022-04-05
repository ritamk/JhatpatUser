import 'package:flutter/material.dart';

BoxDecoration bgLinGradient() {
  return const BoxDecoration(
    gradient: LinearGradient(
      colors: <Color>[Color(0xFFDB0C0C), Color(0xFFA80303)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );
}
