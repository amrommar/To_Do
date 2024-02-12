import 'package:flutter/material.dart';
import 'package:to_do/Home/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: home_Screen.routeName,
      routes: {
        home_Screen.routeName: (context) => home_Screen(),
      },
    );
  }
}
