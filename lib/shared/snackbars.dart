import 'package:flutter/material.dart';

ScaffoldFeatureController commonSnackbar(String text, BuildContext context,
    {double textSize = 16.0}) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      text,
      style: TextStyle(fontSize: textSize),
    ),
    padding: const EdgeInsets.all(18.0),
  ));
}
