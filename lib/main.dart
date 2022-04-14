import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jhatpat/services/shared_pref.dart';
import 'package:jhatpat/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSharedPreferences.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: customTheme(),
      home: const WrapperPage(),
    );
  }
}

ThemeData customTheme() {
  return ThemeData(
    fontFamily: "Montserrat",
    appBarTheme: const AppBarTheme(
      titleTextStyle: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: Colors.red,
        fontFamily: "Montserrat",
      ),
      centerTitle: true,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.red,
    ),
    primarySwatch: Colors.blue,
  );
}
