import 'package:flutter/material.dart';

Widget errorWidget(IconData? icon, String? reason) {
  return Center(
    child: Row(
      children: <Widget>[
        icon != null
            ? const Icon(Icons.error, color: Colors.red)
            : Icon(icon, color: Colors.red),
        reason != null
            ? const Text("\tSomething went wrong, please retry.")
            : Text("\t$reason"),
      ],
    ),
  );
}
