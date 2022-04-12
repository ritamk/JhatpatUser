import 'package:flutter/material.dart';

InputDecoration authTextInputDecoration(
    String label, IconData suffixIcon, String? preText) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(20.0),
    fillColor: Colors.white,
    filled: true,
    prefixIcon: Icon(suffixIcon),
    prefixText: preText,
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    border: textFieldBorder(false, 5.0),
    focusedBorder: textFieldBorder(false, 5.0),
    errorBorder: textFieldBorder(false, 5.0),
    errorStyle: const TextStyle(color: Color.fromRGBO(223, 92, 82, 1.0)),
  );
}

InputDecoration searchTextInputDecoration(
    String label, IconData suffixIcon, String? preText) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(20.0),
    fillColor: Colors.white,
    filled: true,
    prefixIcon: Icon(suffixIcon),
    prefixText: preText,
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    border: textFieldBorder(true, 30.0),
    focusedBorder: textFieldBorder(true, 35.0),
    errorBorder: textFieldBorder(true, 30.0),
    errorStyle: const TextStyle(color: Color.fromRGBO(223, 92, 82, 1.0)),
  );
}

OutlineInputBorder textFieldBorder(bool border, double rad) {
  return OutlineInputBorder(
    // borderSide: border ? const BorderSide(width: 0.5) : BorderSide.none,
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.circular(rad),
  );
}
