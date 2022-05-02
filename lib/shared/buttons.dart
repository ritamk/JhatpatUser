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

//  E8:69:8F:69:00:01:04:FE:BA:C5:54:16:C7:A5:B3:7E:AE:1B:16:65
