import 'package:flutter/material.dart';

MaterialButton blackMaterialButtons(void fxn, Widget child) {
  return MaterialButton(
    onPressed: () {
      fxn;
    },
    child: child,
    minWidth: double.infinity,
    elevation: 0.0,
    focusElevation: 0.0,
    highlightElevation: 0.0,
    color: Colors.black,
    textColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
  );
}
