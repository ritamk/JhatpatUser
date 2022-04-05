import 'package:flutter/material.dart';

InputDecoration authTextInputDecoration(
    String label, IconData suffixIcon, String preText) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(20.0),
    fillColor: Colors.white,
    filled: true,
    prefixIcon: Icon(suffixIcon),
    prefixText: preText,
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    border: textFieldBorder(),
    focusedBorder: textFieldBorder(),
    errorBorder: textFieldBorder(),
    errorStyle: const TextStyle(color: Color.fromRGBO(223, 92, 82, 1.0)),
  );
}

OutlineInputBorder textFieldBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.circular(5.0),
  );
}
