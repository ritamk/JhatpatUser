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
    border: textFieldBorder(5.0),
    focusedBorder: textFieldBorder(5.0),
    errorBorder: textFieldBorder(5.0),
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
    border: textFieldBorder(30.0),
    focusedBorder: textFieldBorder(35.0),
    errorBorder: textFieldBorder(30.0),
    errorStyle: const TextStyle(color: Color.fromRGBO(223, 92, 82, 1.0)),
  );
}

OutlineInputBorder textFieldBorder(double rad) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(rad),
  );
}
