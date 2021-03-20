import 'package:flutter/material.dart';
import 'package:lanterner/pages/login.dart';

void main() {
  runApp(MyApp());
}

Map<int, Color> color = {
  50: Color.fromRGBO(27, 30, 40, .1),
  100: Color.fromRGBO(27, 30, 40, .2),
  200: Color.fromRGBO(27, 30, 40, .3),
  300: Color.fromRGBO(27, 30, 40, .4),
  400: Color.fromRGBO(27, 30, 40, .5),
  500: Color.fromRGBO(27, 30, 40, .6),
  600: Color.fromRGBO(27, 30, 40, .7),
  700: Color.fromRGBO(27, 30, 40, .8),
  800: Color.fromRGBO(27, 30, 40, .9),
  900: Color.fromRGBO(27, 30, 40, 1),
};
Map<int, Color> color2 = {
  50: Color.fromRGBO(44, 193, 215, .1),
  100: Color.fromRGBO(44, 193, 215, .2),
  200: Color.fromRGBO(44, 193, 215, .3),
  300: Color.fromRGBO(44, 193, 215, .4),
  400: Color.fromRGBO(44, 193, 215, .5),
  500: Color.fromRGBO(44, 193, 215, .6),
  600: Color.fromRGBO(44, 193, 215, .7),
  700: Color.fromRGBO(44, 193, 215, .8),
  800: Color.fromRGBO(44, 193, 215, .9),
  900: Color.fromRGBO(44, 193, 215, 1),
};

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lanterner',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF1B1E28, color),
        accentColor: MaterialColor(0xFF2CC1D7, color2),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'OpenSans-Regular',
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 72.0,
          ),
          bodyText2: TextStyle(color: Colors.grey, fontSize: 16),
          headline4:
              TextStyle(color: Theme.of(context).accentColor, fontSize: 16),
          button: TextStyle(
              color: Colors.white,
              fontSize: 18), //text with the accent color for links
        ),
      ),
      home: Login(),
    );
  }
}
